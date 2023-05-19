{ inputs, lib, pkgs, config, ... }:
{
  imports = [
    inputs.srvos.nixosModules.common
    # inputs.srvos.nixosModules.mixins-telegraf
    # config.flake.nixosModules.mixins-common-networking
    ../mixins/common/networking.nix
  ];

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "root" "@wheel" ];

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
      tcpdump
    ];
  };
}
