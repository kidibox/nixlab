import { App, CloudBackend, NamedCloudWorkspace } from "cdktf";
import { K8sClusterStack } from "./stacks/k8s-cluster";
import { IsoStack } from "./stacks/iso";
// import { K8sBootstrapStack } from "./stacks/k8s-bootstrap";

const app = new App();

const iso = new IsoStack(app, "nix-iso");
new CloudBackend(iso, {
  hostname: "app.terraform.io",
  organization: "kidibox",
  workspaces: new NamedCloudWorkspace("nix-iso"),
});

const infra = new K8sClusterStack(app, "k8s-cluster-infra");
new CloudBackend(infra, {
  hostname: "app.terraform.io",
  organization: "kidibox",
  workspaces: new NamedCloudWorkspace("k8s-cluster-infra"),
});

// const bootstrap = new K8sBootstrapStack(app, "k8s-bootstrap-infra", infra);
// new CloudBackend(bootstrap, {
//   hostname: "app.terraform.io",
//   organization: "kidibox",
//   workspaces: new NamedCloudWorkspace("k8s-bootstrap-infra"),
// });

app.synth();
