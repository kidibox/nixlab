import { Construct } from "constructs";
import { TerraformStack } from "cdktf";
import { NixosVm, RouterosProvider } from "../../constructs/";
import { ProxmoxProvider } from "../../constructs";
import { MacaddressProvider } from "../../.gen/providers/macaddress/provider";
import { SopsProvider } from "../../.gen/providers/sops/provider";

export class InfraStack extends TerraformStack {
  constructor(scope: Construct, id: string, isoFileId: string) {
    super(scope, id);

    new SopsProvider(this, "sops");
    new ProxmoxProvider(this, "proxmox");
    new RouterosProvider(this, "routeros");
    new MacaddressProvider(this, "macaddress");

    const pg = new NixosVm(this, "pg0", {
      isoFileId,
      ip: "10.0.100.190",
      dnsName: "pg.kidibox.net",
    });
    new NixosVm(this, "control-plane-0", {
      dependsOn: [pg.deploy],
      isoFileId,
      tags: ["k3s"],
      ip: "10.0.100.180",
    });
    new NixosVm(this, "control-plane-1", {
      dependsOn: [pg.deploy],
      isoFileId,
      tags: ["k3s"],
      ip: "10.0.100.181",
    });
  }
}
