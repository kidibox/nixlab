{ self, flake-parts-lib, inputs, config, ... }:
let
  inherit (flake-parts-lib) importApply;
  # hypernix = 
in
{
  flake = {
    nixosConfigurations = {
      hypernix = inputs.nixpkgs.lib.nixosSystem {
        # specialArgs = { inherit inputs; };
        modules = [
          ./hypernix
          # (importApply ./hypernix { localFlake = self; })

          # config.flake.nixosModules.mixins-nix
          # config.flake.nixosModules.mixins-impermanence
          # config.flake.nixosModules.profiles-server
          # config.flake.nixosModules.profiles-hypervisor
        ];
      };

      testvm1 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./testvm1
          # config.flake.nixosModules.mixins-nix
          # config.flake.nixosModules.mixins-impermanence
        ];
      };

      microvm1 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.microvm.nixosModules.microvm
          {
            microvm = {
              hypervisor = "qemu";
              interfaces = [
                {
                  id = "eth0";
                  type = "bridge";
                  bridge = "br100";
                  mac = "58:DB:A7:29:A4:45";
                }
              ];
            };
          }
          ../modules/common.nix
          {
            nixpkgs.hostPlatform.system = "x86_64-linux";
            networking.hostName = "microvm1";
            services.openssh.enable = true;
          }
        ];
      };
    };
  };
}

