{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    srvos = {
      url = "github:numtide/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let
      inherit (self) outputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      # debug = true;

      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        ./hosts/flake-module.nix
        ./modules/flake-module.nix
        ./terraform/flake-module.nix
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.
        # packages = {
        #   iso = inputs.nixos-generators.nixosGenerate {
        #     inherit system;
        #
        #     format = "iso";
        #
        #     modules = [ ./hosts/iso ];
        #   };
        # };

        devshells.default = {
          packages = with pkgs; [
            treefmt
            terragrunt
            terraform
            terraform-ls
          ];
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          package = pkgs.treefmt;

          programs = {
            nixpkgs-fmt.enable = true;
            terraform.enable = true;
          };
        };
      };

      # flake = {
      #   nixosConfigurations = {
      #     # The usual flake attributes can be defined here, including x fmtsystem-
      #     # agnostic ones like nixosModule and system-enumerating ones, although
      #     # those are more easily expressed in perSystem.
      #
      #     # iso = inputs.nixpkgs.lib.nixosSystem {
      #     #   specialArgs = { inherit inputs; };
      #     #   modules = [ ./hosts/iso ];
      #     # };
      #
      #     hypernix = inputs.nixpkgs.lib.nixosSystem {
      #       specialArgs = { inherit inputs outputs; };
      #       modules = [ ./hosts/hypernix ];
      #     };
      #     testvm1 = inputs.nixpkgs.lib.nixosSystem {
      #       specialArgs = { inherit inputs outputs; };
      #       modules = [
      #         ./hosts/testvm1
      #       ];
      #     };
      #   };
      #
      #   nixosModules = import ./modules/nixos { inherit self; };
      # };
    };
}
