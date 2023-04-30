{ self, lib, inputs, ... }:
{
  flake.nixosModules = import ./nixos { inherit self lib; };
}
