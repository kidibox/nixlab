{ pkgs, inputs, ... }:
{
  imports = [
    inputs.microvm.nixosModules.host
  ];

  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  # required by libvirtd
  security.polkit.enable = true;

  # FIXME figure out why it's not booting
  # virtualisation.kvmgt.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf.enable = true;
    };
    allowedBridges = [ "br10" "br100" ];
    onShutdown = "shutdown";
  };

  virtualisation.podman = {
    enable = true;
  };

  services.nomad = {
    enable = false;
    dropPrivileges = true;
    extraPackages = with pkgs; [
      cni-plugins
      multus-cni
      qemu_full
    ];
    settings = {
      log_json = true;
      server = {
        enabled = true;
        bootstrap_expect = 1;
      };
      client = {
        enabled = true;
        artifact = {
          disable_filesystem_isolation = true;
        };
      };
      ui = {
        enabled = true;
        consul = {
          ui_url = "http://10.0.10.20:8500";
        };
      };
      consul = {
        address = "127.0.0.1:8500";
      };
      plugin.nomad-driver-podman.config = {
        # socket_path = "unix:///run/podman/podman.sock";
      };
    };
    extraSettingsPlugins = with pkgs; [
      nomad-driver-podman
    ];
  };

  services.consul = {
    enable = false;
    dropPrivileges = true;
    webUi = true;
    extraConfig = {
      bootstrap_expect = 1;
      server = true;
      client_addr = "0.0.0.0";
    };
  };

  networking.firewall.allowedTCPPorts = [ 4646 8500 ];
}
