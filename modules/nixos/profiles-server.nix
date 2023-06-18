{ lib, pkgs, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.common
    # inputs.srvos.nixosModules.common
    # inputs.srvos.nixosModules.mixins-telegraf
    # config.flake.nixosModules.mixins-common-networking
    # inputs.sops-nix.nixosModules.sops
    ./mixins/common
    ./mixins/observable/monitoring.nix
    ./mixins/observable/logging.nix
    ./mixins-impermanence.nix
  ];

  # Enable SSH everywhere
  services.openssh.enable = true;

  # No need for sound on a server
  sound.enable = false;

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;

  environment = {
    systemPackages = with pkgs; [
      vim
      tmux
      htop
      powertop
      pciutils # for lspci
      usbutils # for lsusb
      tcpdump
    ];
  };

  # # This is pulled in by the container profile, but it seems broken and causes
  # # unecessary rebuilds.
  # environment.noXlibs = false;
  #
  # # Allow sudo from the @wheel group
  # security.sudo.enable = true;

  services.iperf3.enable = true;
  services.iperf3.openFirewall = true;
}
