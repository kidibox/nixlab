{ lib, ... }:
{
  networking.useNetworkd = lib.mkDefault true;
  networking.useDHCP = true;
}
