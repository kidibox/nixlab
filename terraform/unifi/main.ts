import { Construct } from "constructs";
import { App, TerraformStack, CloudBackend, NamedCloudWorkspace } from "cdktf";
import { Controller } from "./controller";
import { ProxmoxProvider } from "./.gen/providers/proxmox/provider";
import { SopsProvider } from "./.gen/providers/sops/provider";
import { DataSopsFile } from "./.gen/providers/sops/data-sops-file";
import path = require("path");

class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new SopsProvider(this, "sops");

    const data = new DataSopsFile(this, "secrets", {
      sourceFile: path.resolve(
        `${__dirname}/../../configs/home/terraform/secrets.sops.yaml`,
      ),
    });

    new ProxmoxProvider(this, "proxmox", {
      endpoint: "https://pve.servers.home.kidibox.net:8006",
      username: data.data.lookup("proxmox_username"),
      password: data.data.lookup("proxmox_password"),
    });

    new Controller(
      this,
      "controller",
      "local:iso/5bzn97rf4sf4ff6z41b4xd34rf0i9bli-nixos-23.11.20231104.85f1ba3-x86_64-linux.iso.iso",
    );
  }
}

const app = new App();
const stack = new MyStack(app, "unifi");
new CloudBackend(stack, {
  hostname: "app.terraform.io",
  organization: "kidibox",
  workspaces: new NamedCloudWorkspace("unifi-home"),
});
app.synth();
