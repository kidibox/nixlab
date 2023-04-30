{ self, inputs, config, ... }:
{
  flake = {
    nixosConfigurations = {
      hypernix = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hypernix

          config.flake.nixosModules.mixins-nix
          config.flake.nixosModules.mixins-impermanence
          config.flake.nixosModules.profiles-server
          config.flake.nixosModules.profiles-hypervisor
        ];
      };

      testvm1 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./testvm1
          config.flake.nixosModules.mixins-nix
          config.flake.nixosModules.mixins-impermanence
        ];
      };
    };
  };
}
