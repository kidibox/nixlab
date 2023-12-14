import { Construct } from "constructs";
import { Macaddress } from "../.gen/providers/macaddress/macaddress";
import { VirtualEnvironmentVm } from "../.gen/providers/proxmox/virtual-environment-vm";
import { TerraformMetaArguments } from "cdktf";
import { IpDnsRecord } from "../.gen/providers/routeros/ip-dns-record";
import { VirtualEnvironmentFile } from "../.gen/providers/proxmox/virtual-environment-file";

export interface KairosVmConfig extends TerraformMetaArguments {
  nodeName: string;
  isoFileId: string;
  tags?: string[];
}
export class KairosVm extends Construct {
  vm: VirtualEnvironmentVm;
  mac: Macaddress;
  // lease: IpDhcpServerLease;
  record?: IpDnsRecord;
  cloudConfig: VirtualEnvironmentFile;

  constructor(scope: Construct, name: string, config: KairosVmConfig) {
    super(scope, name);

    this.mac = new Macaddress(this, "mac", {
      // Proxmox official prefix
      prefix: [0xbc, 0x24, 0x11],
    });

    this.cloudConfig = new VirtualEnvironmentFile(this, "cloudInit", {
      contentType: "snippets",
      datastoreId: "local",
      nodeName: config.nodeName,
      sourceRaw: {
        data: [
          "#cloud-config",
          `hostname: ${name}`,
          "install:",
          "  device: /dev/vda",
          "  reboot: true",
          "  poweroff: true",
          "  auto: true",
          "users:",
          "- name: kid",
          "  groups:",
          "  - admin",
          "  ssh_authorized_keys:",
          "  - github:kid",
          "k3s-agent:",
          "  enabled: true",
          // "  args:",
          // "  - --datastore-endpoint postgresql://k3s@pg.kidibox.net/k3s",
          "  env:",
          "    K3S_TOKEN: foo",
          "    K3S_URL: https://10.0.100.189:6443",
        ].join("\n"),
        fileName: `${name}.yaml`,
      },
    });

    this.vm = new VirtualEnvironmentVm(this, "vm", {
      // dependsOn: [this.lease],
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
      initialization: {
        datastoreId: "local-zfs",
        // ipConfig: [
        //   {
        //     ipv4: {
        //       address: "dhcp",
        //     },
        //   },
        // ],
        userDataFileId: this.cloudConfig.id,
        // userAccount: {
        //   username: "kid",
        //   keys: [
        //     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCePt+kuDk6ChV7cxo1iBXyA0trZTmhK8YUwwx+UJ2ELYX3fx6kFte68zZ7G5PJ8fclpC5ZKesC/SXGVkfuGq9J+PFekRNF6QlzEz15Sx9eMNYNiBc5KFmeoV6d4BT3ErL6w086cpYXOGvtN/vdsfC5HpO3gZ/RMwrnB9056iiKXECWPvCTG5/6wfaUFW3CcNAJ4o9/uCQD8eAUyKUE+Kadxzd8pasRc1pzN9pBXYMmgrb4H3ICXFHVPkafXevWTdp4Y1X7HoLuqF2T163BtrEjWNnoUL0yJDpukvMQkkHiHWm51u/f4EwXmwzBqRHKFcpeYrWsAM9ymQbrCnBJRy8uyBqnQVzJpsjq2Za+60P4BaeK8mjOIKWS+6/o0Vz4e9mabO2xHkzOI2bECDkOg4ycztPOoNK7LBbfZ060IJv3+td0LeCUphbPxMjKEbjNCWJ7xXdV2r9eHebFfsv6hH381K458ucYTQQN5dc9HrFQdq7CQejwL+sPeJIL/eLHiec= kid@nixos",
        //   ],
        // },
      },
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
  }
}
