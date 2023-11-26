import { App, CloudBackend, NamedCloudWorkspace } from "cdktf";
import { InfraStack } from "./stacks/k8s-cluster";
import { IsoStack } from "./stacks/iso";

const app = new App();

const iso = new IsoStack(app, "nix-iso");
new CloudBackend(iso, {
  hostname: "app.terraform.io",
  organization: "kidibox",
  workspaces: new NamedCloudWorkspace("nix-iso"),
});

const infra = new InfraStack(app, "k8s-cluster-infra", iso.isoFile.id);
new CloudBackend(infra, {
  hostname: "app.terraform.io",
  organization: "kidibox",
  workspaces: new NamedCloudWorkspace("k8s-cluster-infra"),
});

app.synth();
