{ inputs }:
{ self, lib, ... }:
{
  flake.nixosModules = import ./nixos { inherit self inputs lib; };
}
