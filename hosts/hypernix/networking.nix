{ lib, ... }:
{
  networking.useDHCP = lib.mkForce false;
  systemd.network = {
    netdevs = {
      # br10 = {
      #   netdevConfig = {
      #     Name = "br10";
      #     Kind = "bridge";
      #   };
      # };
      br100 = {
        netdevConfig = {
          Name = "br100";
          Kind = "bridge";
        };
      };
      # srv = {
      #   netdevConfig = {
      #     Name = "srv";
      #     Kind = "vlan";
      #   };
      #   vlanConfig.Id = 10;
      # };
      lan = {
        netdevConfig = {
          Name = "lan";
          Kind = "vlan";
        };
        vlanConfig.Id = 100;
      };
    };
    networks = {
      # br10 = {
      #   name = "br10";
      #   DHCP = "ipv4";
      # };
      br100 = {
        name = "br100";
        linkConfig = {
          RequiredForOnline = false;
        };
        networkConfig = {
          LinkLocalAddressing = "no";
          LLDP = "no";
          EmitLLDP = "no";
          IPv6AcceptRA = "no";
          IPv6SendRA = "no";
        };
      };
      enp3s0 = {
        name = "enp3s0";
        DHCP = "ipv4";
        vlan = [
          # "srv"
          "lan"
        ];
        # linkConfig = {
        #   RequiredForOnline = false;
        # };
        # # Disable all the autoconfiguration magic we don't need a link without VLAN
        # networkConfig = {
        #   LinkLocalAddressing = "no";
        #   LLDP = "no";
        #   EmitLLDP = "no";
        #   IPv6AcceptRA = "no";
        #   IPv6SendRA = "no";
        # };
      };
      # srv = {
      #   name = "srv";
      #   bridge = [ "br10" ];
      # };
      lan = {
        name = "lan";
        bridge = [ "br100" ];
      };
    };
  };

}
