{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    startWhenNeeded = true;
    drivers = with pkgs; [ brlaser ];
    stateless = true;

    browsing = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    defaultShared = true;
  };

  networking.firewall.allowedTCPPorts = [ 631 ];
  networking.firewall.allowedUDPPorts = [ 631 ];
}
