import { Construct } from "constructs";
import { DataTerraformRemoteState, TerraformStack } from "cdktf";
import { NixosVm, RouterosProvider } from "../../constructs/";
import { ProxmoxProvider } from "../../constructs";
import { MacaddressProvider } from "../../.gen/providers/macaddress/provider";
import { SopsProvider } from "../../.gen/providers/sops/provider";
import { RemoteProvider } from "../../.gen/providers/remote/provider";

export class K8sClusterStack extends TerraformStack {
  // clusterCaCertificate: TerraformOutput;
  // clientCertificate: TerraformOutput;
  clientKey: any;
  // cluster_host: TerraformOutput;
  constructor(
    scope: Construct,
    id: string,
    // isoFileId: string,

    // _isoFileIds: { [_: string]: string },
  ) {
    super(scope, id);

    new SopsProvider(this, "sops");
    new ProxmoxProvider(this, "proxmox");
    new RouterosProvider(this, "routeros");
    new MacaddressProvider(this, "macaddress");

    const remoteNixIso = new DataTerraformRemoteState(this, "remoteNixIso", {
      organization: "kidibox",
      workspaces: {
        name: "nix-iso",
      },
    });

    new NixosVm(this, "cloudflared0", remoteNixIso, {
      nodeName: "pve0",
      ip: "10.0.30.10",
      vlanId: 30,
    });
    new NixosVm(this, "cloudflared1", remoteNixIso, {
      nodeName: "pve1",
      ip: "10.0.30.11",
      vlanId: 30,
    });
    // const pg = new NixosVm(this, "pg0", isoFiles, {
    //   nodeName: "pve0",
    //   ip: "10.0.100.190",
    //   dnsName: "pg.kidibox.net",
    // });
    // const cp0 = new NixosVm(this, "control-plane-0", isoFiles, {
    //   nodeName: "pve0",
    //   dependsOn: [pg.deploy],
    //   tags: ["k3s"],
    //   ip: "10.0.100.180",
    // });
    // new NixosVm(this, "control-plane-1", isoFiles, {
    //   nodeName: "pve1",
    //   dependsOn: [pg.deploy],
    //   tags: ["k3s"],
    //   ip: "10.0.100.181",
    // });
    //
    // new KairosVm(this, "kairos-k3s-agent-0", {
    //   nodeName: "pve0",
    //   isoFileId:
    //     "local:iso/kairos-rockylinux-9-standard-amd64-generic-v2.4.2-k3sv1.28.2_k3s1.iso",
    // });
    // // new KairosVm(this, "kairos-k3s-agent-1", {
    // //   nodeName: "pve1",
    // //   isoFileId:
    // //     "local:iso/kairos-rockylinux-9-standard-amd64-generic-v2.4.2-k3sv1.28.2_k3s1.iso",
    // // });
    //
    new RemoteProvider(this, "remote", {});

    // const kubeconfig = new DataRemoteFile(this, "kubeconfigFile", {
    //   dependsOn: [cp0.deploy],
    //   conn: {
    //     host: cp0.deploy.targetHost,
    //     user: "root",
    //     privateKeyPath: `/home/kid/.ssh/id_rsa`,
    //   },
    //   path: "/etc/rancher/k3s/k3s.yaml",
    // });
    //
    // this.cluster_host = new TerraformOutput(this, "cluster_host", {
    //   value: "https://10.0.100.189:6443",
    // });
    //
    // this.clusterCaCertificate = new TerraformOutput(
    //   this,
    //   "cluster_ca_certificate",
    //   {
    //     sensitive: true,
    //     value: Fn.base64decode(
    //       Fn.lookupNested(Fn.yamldecode(kubeconfig.content), [
    //         "clusters",
    //         0,
    //         "cluster",
    //         "certificate-authority-data",
    //       ]),
    //     ),
    //   },
    // );
    //
    // this.clientCertificate = new TerraformOutput(this, "client_certificate", {
    //   sensitive: true,
    //   value: Fn.base64decode(
    //     Fn.lookupNested(Fn.yamldecode(kubeconfig.content), [
    //       "users",
    //       0,
    //       "user",
    //       "client-certificate-data",
    //     ]),
    //   ),
    // });
    //
    // this.clientKey = new TerraformOutput(this, "client_key", {
    //   sensitive: true,
    //   value: Fn.base64decode(
    //     Fn.lookupNested(Fn.yamldecode(kubeconfig.content), [
    //       "users",
    //       0,
    //       "user",
    //       "client-key-data",
    //     ]),
    //   ),
    // });
    //
    // new Manifest(this, "cilium", {
    //   dependsOn: [kubeconfig],
    //   manifest: {
    //     apiVersion: "helm.cattle.io/v1",
    //     kind: "HelmChart",
    //     metadata: {
    //       name: "cilium",
    //       namespace: "kube-system",
    //     },
    //     spec: {
    //       bootstrap: true,
    //       repo: "https://helm.cilium.io",
    //       chart: "cilium",
    //       version: "1.14.3",
    //       targetNamespace: "kube-system",
    //       valuesContent: Fn.yamlencode({
    //         k8sServiceHost: "10.0.100.189",
    //         k8sServicePort: 6443,
    //         kubeProxyReplacement: true,
    //         bgpControlPlane: {
    //           enabled: true,
    //         },
    //         operator: {
    //           replicas: 2,
    //         },
    //         ipam: {
    //           operator: {
    //             clusterPoolIPv4PodCIDRList: ["10.42.0.0/16"],
    //           },
    //         },
    //       }),
    //     },
    //   },
    // });
  }
}
