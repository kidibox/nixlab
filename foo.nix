{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./flake ]; };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; };
    nix-common = { url = "github:viperML/nix-common"; };
    nh = { url = "github:viperML/nh"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-parts.follows = "flake-parts"; };
    nix = { url = "github:NixOS/nix/2.16.1"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-compat.follows = "flake-compat"; };
    home-manager-wsl = { url = "github:viperML/home-manager-wsl"; inputs.nixpkgs.follows = "nixpkgs"; inputs.home-manager.follows = "home-manager"; };
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils = { url = "github:numtide/flake-utils"; };
    home-manager = { url = "github:nix-community/home-manager/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    deploy-rs = { url = "github:serokell/deploy-rs"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-compat.follows = "flake-compat"; };
    nix-gaming = { url = "github:fufexan/nix-gaming"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-index-database = { url = "github:Mic92/nix-index-database"; };
    nil = { url = "github:oxalica/nil"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    vscode-server = { url = "github:msteen/nixos-vscode-server"; inputs.nixpkgs.follows = "nixpkgs"; };
    nvfetcher = { url = "github:berberman/nvfetcher/0.6.1"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; inputs.flake-compat.follows = "flake-compat"; };
    envfs = { url = "github:Mic92/envfs"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-parts.follows = "flake-parts"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
  };
}