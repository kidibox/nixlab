{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault true;
  networking.useNetworkd = lib.mkDefault true;
}
