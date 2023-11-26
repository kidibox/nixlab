{ lib, ... }:
{
  # Higher priority than srvos's networking mopdule
  networking.useDHCP = lib.mkOverride 900 true;
  networking.useNetworkd = lib.mkDefault true;
}
