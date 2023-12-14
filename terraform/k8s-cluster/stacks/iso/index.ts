import { Construct } from "constructs";
import { TerraformStack, Fn, TerraformOutput } from "cdktf";
import { NixBuild } from "../../.gen/modules/nix-build";
import { VirtualEnvironmentFile } from "../../.gen/providers/proxmox/virtual-environment-file";
import { ProxmoxProvider } from "../../constructs";
import { SopsProvider } from "../../.gen/providers/sops/provider";

export class IsoStack extends TerraformStack {
  isoFileIds: TerraformOutput;

  constructor(scope: Construct, id: string) {
    super(scope, id);

    new SopsProvider(this, "sops");
    new ProxmoxProvider(this, "proxmox");

    const iso = new NixBuild(this, "isoBuild", {
      attribute: ".#nixosConfigurations.installer.config.formats.install-iso",
    });

    const isoFiles = [
      new VirtualEnvironmentFile(this, "pve0", {
        datastoreId: "local",
        contentType: "iso",
        nodeName: "pve0",
        sourceFile: {
          path: Fn.lookup(iso.resultOutput, "out"),
        },
      }),
      new VirtualEnvironmentFile(this, "pve1", {
        datastoreId: "local",
        contentType: "iso",
        nodeName: "pve1",
        sourceFile: {
          path: Fn.lookup(iso.resultOutput, "out"),
        },
      }),
    ];

    // new TerraformOutput(this, "isoOutput", {
    //   value: Fn.lookup(iso.resultOutput, "out"),
    // });

    this.isoFileIds = new TerraformOutput(this, "isoFileIds", {
      value: isoFiles.reduce(
        (value, f) => ({ ...value, [f.nodeName]: f.id }),
        {},
      ),
    });
  }
}
