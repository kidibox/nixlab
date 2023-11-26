import { Fn } from "cdktf";
import { VirtualEnvironmentVm } from "./.gen/providers/proxmox/virtual-environment-vm";
import { AllInOne } from "./.gen/modules/all-in-one";
import { Construct } from "constructs";

export class Controller extends Construct {
  vm: VirtualEnvironmentVm;
  deploy: AllInOne;

  constructor(scope: Construct, name: string, fileId: string) {
    super(scope, name);

    this.vm = new VirtualEnvironmentVm(this, "unifi", {
      tags: ["terraform", "nixos"],
      name: "unifi",
      nodeName: "pve",
      machine: "q35",
      bios: "ovmf",
      bootOrder: ["virtio0", "ide0"],
      cpu: {
        cores: 2,
        type: "x86-64-v2-AES",
      },
      memory: {
        dedicated: 2048,
        shared: 2048,
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
        fileId,
      },
      networkDevice: [
        {
          bridge: "vmbr0",
          vlanId: 99,
        },
      ],
    });

    this.deploy = new AllInOne(this, `deploy`, {
      nixosSystemAttr: `.#nixosConfigurations.unifi.config.system.build.toplevel`,
      nixosPartitionerAttr: `.#nixosConfigurations.unifi.config.system.build.diskoScript`,
      targetHost: Fn.element(this.vm.ipv4Addresses.get(1), 0),
    });
  }
}
