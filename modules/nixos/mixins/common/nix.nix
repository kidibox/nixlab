{ inputs, ... }:
{
  # TODO find a better place for this?
  system.stateVersion = "23.05";

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];

    settings = {
      allowed-users = [ "root" "@wheel" ];
      trusted-users = [ "root" "@wheel" ];

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://kidibox.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "kidibox.cachix.org-1:BN875x9JUW61souPxjf7eA5Uh2k3A1OSA1JIb/axGGE="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
  };
}
