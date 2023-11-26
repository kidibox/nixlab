import { Construct } from "constructs";
import { Macaddress } from "../.gen/providers/macaddress/macaddress";
import { VirtualEnvironmentVm } from "../.gen/providers/proxmox/virtual-environment-vm";
import { AllInOne } from "../.gen/modules/all-in-one";
import { TerraformMetaArguments } from "cdktf";
import { RosStaticHost } from "../.gen/modules/ros_static_host";

export interface NixosVmConfig extends TerraformMetaArguments {
  isoFileId: string;
  ip: string;
  tags?: string[];
  dnsName?: string;
}
export class NixosVm extends Construct {
  vm: VirtualEnvironmentVm;
  deploy: AllInOne;
  mac: Macaddress;
  staticHost: RosStaticHost;

  constructor(scope: Construct, name: string, config: NixosVmConfig) {
    super(scope, name);

    this.mac = new Macaddress(this, "mac", {
      // Proxmox official prefix
      prefix: [0xbc, 0x24, 0x11],
    });

    this.staticHost = new RosStaticHost(this, "staticHost", {
      ipAddress: config.ip,
      macAddress: this.mac.address,
      dnsName: config.dnsName,
    });

    this.vm = new VirtualEnvironmentVm(this, "vm", {
      dependsOn: [this.staticHost],
      tags: ["terraform", "nixos"].concat(config.tags || []),
      name: name,
      nodeName: "pve",
      machine: "q35",
      bios: "ovmf",
      bootOrder: ["virtio0", "ide0"],
      cpu: {
        cores: 4,
        type: "x86-64-v2-AES",
      },
      memory: {
        dedicated: 4096,
        shared: 4096,
        floating: 512,
      },
      agent: {
        enabled: true,
        trim: true,
      },
      efiDisk: {
        datastoreId: "local-zfs",
        fileFormat: "raw",
      },
      disk: [
        {
          datastoreId: "local-zfs",
          interface: "virtio0",
          fileFormat: "raw",
          size: 32,
        },
      ],
      cdrom: {
        enabled: true,
        interface: "ide0",
        fileId: config.isoFileId,
      },
      networkDevice: [
        {
          bridge: "vmbr0",
          vlanId: 100,
          macAddress: this.mac.address,
        },
      ],
    });

    this.deploy = new AllInOne(this, "deploy", {
      dependsOn: [this.vm],
      nixosSystemAttr: `.#nixosConfigurations.${name}.config.system.build.toplevel`,
      nixosPartitionerAttr: `.#nixosConfigurations.${name}.config.system.build.diskoScript`,

      targetHost: this.staticHost.ipAddress,
      // instanceId: Fn.element(this.vm.ipv4Addresses.get(1), 0),
    });
  }
}
