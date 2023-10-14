{ inputs, ... }:
{
  imports = [
    inputs.microvm.nixosModules.microvm
    ./mixins/common
    ./mixins/observable/monitoring.nix
    # ./mixins/observable/logging.nix
    # ./mixins-impermanence.nix
  ];

  services.openssh.enable = true;

  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
  ];
}
