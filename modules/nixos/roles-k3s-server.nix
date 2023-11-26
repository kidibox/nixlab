{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixlab.k3s;

  # kubeletConfig = pkgs.writeTextFile {
  #   name = "kubelet.config";
  #   text = ''
  #     apiVersion: kubelet.config.k8s.io/v1beta1
  #     kind: KubeletConfiguration
  #
  #     shutdownGracePeriod: 30s
  #     shutdownGracePeriodCriticalPods: 10s
  #   '';
  # };

  # ciliumHelmChart = pkgs.writeTextFile {
  #   name = "cilium.yaml";
  #   text = ''
  #     apiVersion: helm.cattle.io/v1
  #     kind: HelmChart
  #     metadata:
  #       name: cilium
  #       namespace: kube-system
  #     spec:
  #       bootstrap: true
  #       repo: https://helm.cilium.io/
  #       chart: cilium
  #       version: 1.14.3
  #       targetNamespace: kube-system
  #       valuesContent: |-
  #         k8sServiceHost: 10.0.10.20
  #         k8sServicePort: 6443
  #         kubeProxyReplacement: true
  #
  #         # k3s specific
  #         cni:
  #           binPath: /var/lib/rancher/k3s/agent/opt/cni/bin
  #           confPath: /var/lib/rancher/k3s/agent/etc/cni/net.d
  #
  #         bpf:
  #           # does this makes senses with native routing?
  #           masquerade: true
  #
  #         # this breaks ingress on same node
  #         # routingMode: native
  #         # ipv4NativeRoutingCIDR: 10.42.0.0/16
  #         # auto-direct-node-routes: true
  #         # endpointRoutes:
  #         #   enabled: true
  #
  #         bgpControlPlane:
  #           enabled: true
  #         operator:
  #           replicas: 1
  #         ipam:
  #           operator:
  #             clusterPoolIPv4PodCIDRList:
  #               - 10.42.0.0/16
  #
  #
  #         ingressController:
  #           enabled: true
  #           loadbalancerMode: dedicated
  #         gatewayAPI:
  #           enabled: true
  #
  #         hubble:
  #           ui:
  #             enabled: true
  #           relay:
  #             enabled: true
  #   '';
  # };

  # ciliumExtra = pkgs.writeTextFile
  #   {
  #     name = "cilium-extra.yaml";
  #     text = ''
  #       apiVersion: "cilium.io/v2alpha1"
  #       kind: CiliumLoadBalancerIPPool
  #       metadata:
  #         name: "default"
  #       spec:
  #         cidrs:
  #           - cidr: "10.0.50.0/24"
  #       ---
  #       apiVersion: cilium.io/v2alpha1
  #       kind: CiliumBGPPeeringPolicy
  #       metadata:
  #         name: bgp-peering-policy
  #       spec:
  #         nodeSelector:
  #           matchLabels: {}
  #         virtualRouters:
  #           - localASN: 64512
  #             exportPodCIDR: true
  #             neighbors:
  #               - peerAddress: '10.0.10.1/32'
  #                 peerASN: 64512
  #             serviceSelector:
  #               matchExpressions:
  #                 - {key: somekey, operator: NotIn, values: ['never-used-value']}
  #     '';
  #   };
in
{
  options.nixlab.k3s = {
    enable = mkEnableOption "k3s";
  };

  # HACK: https://www.enricobassetti.it/2022/02/k3s-zfs-cgroups-v2/
  # FIX: https://github.com/k3s-io/k3s/discussions/4319

  config = mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        # "--kubelet-arg=\"config=${kubeletConfig}\""
        # "--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
        "--datastore-endpoint=postgres://k3s@pg.kidibox.net:5432/k3s"
        "--token=foo"
        # "--flannel-backend=none"
        # "--disable-kube-proxy"
        "--disable-network-policy"
        "--disable servicelb,traefik"
      ];
    };

    # TODO: remove this part, zfs snapshotter is included in k3s's containerd now
    # virtualisation.containerd = {
    #   enable = true;
    #   settings = {
    #     plugins."io.containerd.grpc.v1.cri".cni = {
    #       bin_dir = "/var/lib/rancher/k3s/agent/opt/cni/bin";
    #       conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d";
    #     };
    #   };
    # };

    networking.firewall.enable = lib.mkForce false;
    networking.firewall.allowedTCPPorts = [ 6443 ];

    # system.activationScripts.k3s = ''
    #   mkdir -p /var/lib/rancher/k3s/server/manifests
    #   ln -sf ${ciliumHelmChart} /var/lib/rancher/k3s/server/manifests/cilium.yaml
    #   # ln -sf ${ciliumExtra} /var/lib/rancher/k3s/server/manifests/cilium-extra.yaml
    # '';

    environment.systemPackages = with pkgs; [ k3s kubectl cilium-cli cri-tools hubble ];
    environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };
}
