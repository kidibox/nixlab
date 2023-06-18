{ withSystem, inputs, config, lib, ... }: {
  flake = withSystem "x86_64-linux" (
    { system
      # , pkgs
    , ...
    }:
    let
      hostName = "hypernix";
    in
    {
      nixosConfigurations.${hostName} =
        let
          specialArgs = { inherit inputs; };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system specialArgs; # pkgs;

          modules = lib.lists.flatten [
            ({ modulesPath, ... }: {
              imports = [
                "${modulesPath}/installer/scan/not-detected.nix"
                "${modulesPath}/profiles/minimal.nix"
                "${modulesPath}/profiles/headless.nix"
              ];
            })

            (builtins.attrValues {
              inherit (inputs.nixos-hardware.nixosModules)
                common-pc
                common-pc-ssd
                common-cpu-intel
                ;

              inherit (config.flake.nixosModules)
                profiles-server
                profiles-hypervisor
                roles-syslog
                ;
            })

            inputs.disko.nixosModules.disko
            inputs.srvos.nixosModules.common

            ./hardware-configuration.nix
            ./networking.nix
            {
              networking = {
                inherit hostName;
                # required by ZFS
                hostId = "385f9236";
              };
            }
          ];
        };
    }
  );
}
