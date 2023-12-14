import { Construct } from "constructs";
import { Fn, TerraformIterator, TerraformOutput, TerraformStack } from "cdktf";
import { K8sClusterStack } from "../k8s-cluster";
import { KubernetesProvider } from "@cdktf/provider-kubernetes/lib/provider";
import { Manifest } from "@cdktf/provider-kubernetes/lib/manifest";
import { DataHttp } from "@cdktf/provider-http/lib/data-http";
import { HttpProvider } from "@cdktf/provider-http/lib/provider";

export class K8sBootstrapStack extends TerraformStack {
  constructor(scope: Construct, id: string, cluster: K8sClusterStack) {
    super(scope, id);

    new HttpProvider(this, "http");
    new KubernetesProvider(this, "kubernetes", {
      host: cluster.cluster_host.value,
      clientKey: cluster.clientKey.value,
      clientCertificate: cluster.clientCertificate.value,
      clusterCaCertificate: cluster.clusterCaCertificate.value,
    });

    const gatewayManifests = new DataHttp(this, "gateway_manifests", {
      url: "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml",
    });
    //
    const iterator = TerraformIterator.fromList(
      Fn.split("---", gatewayManifests.responseBody),
    );
    new Manifest(this, "manifest", {
      forEach: iterator,
      manifest: Fn.yamldecode("---" + iterator.value),
    });
    // const manifests = Fn.split("---", gatewayManifests.responseBody)
    new TerraformOutput(this, "manfiest", {
      value: Fn.split("---", gatewayManifests.responseBody),
    });

    new Manifest(this, "cilium", {
      manifest: {
        apiVersion: "helm.cattle.io/v1",
        kind: "HelmChart",
        metadata: {
          name: "cilium",
          namespace: "kube-system",
        },
        spec: {
          bootstrap: true,
          repo: "https://helm.cilium.io",
          chart: "cilium",
          version: "1.14.3",
          targetNamespace: "kube-system",
          valuesContent: Fn.yamlencode({
            k8sServiceHost: "10.0.100.189",
            k8sServicePort: 6443,
            kubeProxyReplacement: true,
            bgpControlPlane: {
              enabled: true,
            },
            operator: {
              replicas: 2,
            },
            ipam: {
              operator: {
                clusterPoolIPv4PodCIDRList: ["10.42.0.0/16"],
              },
            },
          }),
        },
      },
    });
  }
}
