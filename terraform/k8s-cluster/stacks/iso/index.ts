import { Construct } from "constructs";
import { TerraformStack, TerraformOutput, Fn } from "cdktf";
import { NixBuild } from "../../.gen/modules/nix-build";
import { VirtualEnvironmentFile } from "../../.gen/providers/proxmox/virtual-environment-file";
import { ProxmoxProvider } from "../../constructs";
import { SopsProvider } from "../../.gen/providers/sops/provider";

export class IsoStack extends TerraformStack {
  isoFile: VirtualEnvironmentFile;

  constructor(scope: Construct, id: string) {
    super(scope, id);

    new SopsProvider(this, "sops");
    new ProxmoxProvider(this, "proxmox");

    const iso = new NixBuild(this, "isoBuild", {
      attribute: ".#nixosConfigurations.installer.config.formats.install-iso",
    });

    this.isoFile = new VirtualEnvironmentFile(this, "isoFile", {
      datastoreId: "local",
      contentType: "iso",
      nodeName: "pve",
      sourceFile: {
        path: Fn.lookup(iso.resultOutput, "out"),
      },
    });

    new TerraformOutput(this, "isoOutput", {
      value: Fn.lookup(iso.resultOutput, "out"),
    });

    new TerraformOutput(this, "isoFileId", {
      value: this.isoFile.id,
    });
  }
}
