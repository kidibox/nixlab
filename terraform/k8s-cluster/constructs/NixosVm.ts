import { Construct } from "constructs";
import { Macaddress } from "../.gen/providers/macaddress/macaddress";
import { VirtualEnvironmentVm } from "../.gen/providers/proxmox/virtual-environment-vm";
import { AllInOne } from "../.gen/modules/all-in-one";
import { DataTerraformRemoteState, Fn, TerraformMetaArguments } from "cdktf";
import { IpDhcpServerLease } from "../.gen/providers/routeros/ip-dhcp-server-lease";
import { IpDnsRecord } from "../.gen/providers/routeros/ip-dns-record";

const vlanDhcpServer: { [index: number]: string } = {
  99: "adm",
  10: "srv",
  30: "media",
  100: "lan",
};

export interface NixosVmConfig extends TerraformMetaArguments {
  nodeName: string;
  vlanId?: number;
  ip: string;
  tags?: string[];
  dnsName?: string;
}
export class NixosVm extends Construct {
  vm: VirtualEnvironmentVm;
  deploy: AllInOne;
  mac: Macaddress;
  lease: IpDhcpServerLease;
  record?: IpDnsRecord;

  constructor(
    scope: Construct,
    name: string,
    remoteNixIso: DataTerraformRemoteState,
    config: NixosVmConfig,
  ) {
    super(scope, name);

    const vlanId = config.vlanId ?? 100;

    this.mac = new Macaddress(this, "mac", {
      // Proxmox official prefix
      prefix: [0xbc, 0x24, 0x11],
    });

    this.lease = new IpDhcpServerLease(this, "lease", {
      macAddress: Fn.upper(this.mac.address),
      address: config.ip,
      server: vlanDhcpServer[vlanId],
    });

    if (config.dnsName) {
      this.record = new IpDnsRecord(this, "record", {
        type: "A",
        name: config.dnsName,
        address: config.ip,
      });
    }

    // this.staticHost = new RosStaticHost(this, "staticHost", {
    //   ipAddress: config.ip,
    //   macAddress: this.mac.address,
    //   dnsName: config.dnsName,
    // });

    this.vm = new VirtualEnvironmentVm(this, "vm", {
      dependsOn: [this.lease],
      tags: ["terraform", "nixos"].concat(config.tags || []),
      name: name,
      nodeName: config.nodeName,
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
        fileId: Fn.lookup(remoteNixIso.get("isoFileIds"), config.nodeName),
      },
      networkDevice: [
        {
          bridge: "vmbr0",
          vlanId,
          macAddress: this.mac.address,
        },
      ],
    });

    this.deploy = new AllInOne(this, "deploy", {
      dependsOn: [this.vm],
      nixosSystemAttr: `.#nixosConfigurations.${name}.config.system.build.toplevel`,
      nixosPartitionerAttr: `.#nixosConfigurations.${name}.config.system.build.diskoScript`,

      targetHost: this.lease.address,
      // instanceId: Fn.element(this.vm.ipv4Addresses.get(1), 0),
    });
  }
}
