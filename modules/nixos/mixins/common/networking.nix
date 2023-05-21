{ lib, ... }:
{
  networking.useNetworkd = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault true;
}
