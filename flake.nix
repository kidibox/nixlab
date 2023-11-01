{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://kidibox.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "kidibox.cachix.org-1:BN875x9JUW61souPxjf7eA5Uh2k3A1OSA1JIb/axGGE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05-small";

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
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # debug = true;

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        ./lib
        ./hosts
        ./modules/flake-module.nix
        ./terraform/flake-module.nix
      ];

      systems = [
        "x86_64-linux"
        # "aarch64-linux" 
        # "aarch64-darwin" 
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };

          master = import inputs.nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          overlayAttrs = {
            inherit stable master;
          };

          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
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
              cilium-cli
              hubble
              fluxcd
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
