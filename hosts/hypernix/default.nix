{ lib, config, inputs, ... }:
let
  hostName = "hypernix";
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = lib.lists.flatten [
      ({ modulesPath, ... }: {
        imports = [
          "${modulesPath}/installer/scan/not-detected.nix"
          "${modulesPath}/profiles/minimal.nix"
          "${modulesPath}/profiles/headless.nix"
        ];
      })
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModule
      inputs.srvos.nixosModules.common
      # (with config.flake.nixosModules; [
      #   # flake-inputs
      #   # Theses 2 should probably be inlcuded in the server profile
      #   # mixins-nix
      #   # mixins-impermanence
      #   # profiles-server
      #   # profiles-hypervisor
      # ])
      [
        ../../modules/common.nix
        ./hardware-configuration.nix
        ./networking.nix
        (import ./microvms.nix { inherit inputs; })

        {
          nixpkgs.hostPlatform.system = "x86_64-linux";
        }
        {
          # nixpkgs.overlays = [
          #   inputs.deploy-rs.overlay
          # ];
          # services.udev.extraRules = ''
          #   SUBSYSTEM=="pci", ATTR{power/control}="auto"
          #   ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
          #   ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
          # '';

          # TODO move this to common
          # TODO is this even required?
          # services.fwupd.enable = true;
          # hardware.cpu.intel.updateMicrocode = true;

          networking = {
            inherit hostName;
            # required by ZFS
            hostId = "385f9236";
          };

          services.prometheus.exporters.node.enable = true;
          services.prometheus.exporters.node.openFirewall = true;
        }
        (builtins.attrValues {
          inherit (config.flake.nixosModules)
            # flake-inputs
            mixins-nix
            mixins-impermanence
            profiles-server
            profiles-hypervisor
            ;
          inherit (inputs.nixos-hardware.nixosModules)
            common-pc
            common-pc-ssd
            common-cpu-intel
            ;
        })
      ]
    ];
  };
}
