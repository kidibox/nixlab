{ self, modulesPath, inputs, config, lib, ... }:
{
  imports = lib.lists.flatten [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/headless.nix"

    (builtins.attrValues {
      inherit (inputs.nixos-hardware.nixosModules)
        common-pc
        common-pc-ssd
        common-cpu-intel
        ;
    })

    # inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.common

    #
    #   inherit (config.flake.nixosModules)
    #     profiles-server
    #     profiles-hypervisor
    #     roles-syslog
    #     roles-printing
    #     roles-k3s-server
    #     ;
    # })

    ../../modules/nixos/profiles-server.nix
    ../../modules/nixos/profiles-hypervisor.nix
    ../../modules/nixos/roles-syslog.nix
    ../../modules/nixos/roles-printing.nix
    ../../modules/nixos/roles-k3s-server.nix
    #
    ./hardware-configuration.nix
    ./networking.nix
    ./cloudflared.nix
  ];

  # required by ZFS
  networking. hostId = "385f9236";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    self.overlays.default
  ];

  nixlab.k3s.enable = true;
}
