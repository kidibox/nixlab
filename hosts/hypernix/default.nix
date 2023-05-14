{ self, inputs, lib, pkgs, config, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/minimal.nix"
    inputs.impermanence.nixosModule
    ../../modules/common.nix
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/server.nix
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';

  # TODO move this to common
  # services.fwupd.enable = true;
  # hardware.cpu.intel.updateMicrocode = true;

  networking = {
    # required by ZFS
    hostId = "385f9236";
    hostName = "hypernix";
    useDHCP = lib.mkForce false;
  };

  systemd.network = {
    netdevs = {
      br10 = {
        netdevConfig = {
          Name = "br10";
          Kind = "bridge";
        };
        # extraConfig = ''
        #   [Bridge]
        #   STP = true;
        # '';
      };
      br100 = {
        netdevConfig = {
          Name = "br100";
          Kind = "bridge";
        };
        # extraConfig = ''
        #   [Bridge]
        #   STP = true;
        # '';
      };
      srv = {
        netdevConfig = {
          Name = "srv";
          Kind = "vlan";
        };
        vlanConfig.Id = 10;
      };
      lan = {
        netdevConfig = {
          Name = "lan";
          Kind = "vlan";
        };
        vlanConfig.Id = 100;
      };
    };
    networks = {
      br10 = {
        name = "br10";
        DHCP = "ipv4";
      };
      br100 = {
        name = "br100";
        DHCP = "ipv4";
        dhcpV4Config = {
          RouteMetric = 2048;
        };
      };
      enp3s0 = {
        name = "enp3s0";
        vlan = [ "srv" "lan" ];
        # Disable all the autoconfiguration magic we don't need a link without VLAN
        networkConfig = {
          LinkLocalAddressing = "no";
          LLDP = "no";
          EmitLLDP = "no";
          IPv6AcceptRA = "no";
          IPv6SendRA = "no";
        };
      };
      srv = {
        name = "srv";
        bridge = [ "br10" ];
      };
      lan = {
        name = "lan";
        bridge = [ "br100" ];
      };
    };
  };
}

