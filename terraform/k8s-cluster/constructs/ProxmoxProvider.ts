import path = require("path");
import { Construct } from "constructs";
import { DataSopsFile } from "../.gen/providers/sops/data-sops-file";
import * as proxmox from "../.gen/providers/proxmox/provider";

export class ProxmoxProvider extends Construct {
  proxmoxProvider: proxmox.ProxmoxProvider;
  secrets: DataSopsFile;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    this.secrets = new DataSopsFile(this, "secrets", {
      sourceFile: path.resolve(
        `${__dirname}/../../../configs/home/terraform/secrets.sops.yaml`,
      ),
    });

    this.proxmoxProvider = new proxmox.ProxmoxProvider(this, "proxmox", {
      endpoint: "https://pve0.kidibox.net:8006",
      username: this.secrets.data.lookup("proxmox_username"),
      password: this.secrets.data.lookup("proxmox_password"),
      ssh: {
        nodeAttribute: [
          { name: "pve0", address: "10.0.10.10" },
          { name: "pve1", address: "10.0.10.11" },
        ],
      },
    });
  }
}
