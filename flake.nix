{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://kidibox.cachix.org"
      "https://microvm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "kidibox.cachix.org-1:BN875x9JUW61souPxjf7eA5Uh2k3A1OSA1JIb/axGGE="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
    ];
  };

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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # microvm = {
    #   url = "github:oddlama/microvm.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # std = {
    #   url = "github:divnix/std";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # debug = true;

      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        ./lib
        ./hosts
        ./modules/flake-module.nix
        ./terraform/flake-module.nix
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit pkgs system;
            overlays = [
              # self.overlays.default
              # inputs.deploy-rs.overlay
              # inputs.microvm.overlay
              # inputs.deploy-rs.overlay
              # (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
            ];
          };

          devshells.default = {
            packages = with pkgs; [
              nil
              rnix-lsp
              treefmt
              terragrunt
              terraform
              terraform-ls
              cfssl
              deploy-rs
              sops
              age
              ssh-to-age
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

      flake = {
        deploy.nodes.hypernix = {
          hostname = "10.0.10.20";
          profiles.system = {
            user = "root";
            sshUser = "kid";
            remoteBuild = true;
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hypernix;
          };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
      };
    };
}
