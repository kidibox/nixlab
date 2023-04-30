{ self, inputs, lib, pkgs, config, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/minimal.nix"
    # "${modulesPath}/profiles/headless.nix"
    # TODO reenable hyperthreading
    "${modulesPath}/profiles/hardened.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    inputs.impermanence.nixosModule
    ../../modules/common.nix
    ./hardware-configuration.nix
    # inputs.disko.nixosModules.disko
    # inputs.nixos-hardware.nixosModules.common-pc
    # inputs.nixos-hardware.nixosModules.common-pc-ssd
    # outputs.nixosModules.profiles-server
    # config.nixosModules.profiles-server
    # ../../modules/nixos/profiles/server.nix
    # inputs.nixos-hardware.nixosModules.common-cpu-intel
    # config.flake.nixosModules.profiles-server
  ];

  # nixpkgs.hostPlatform.system = "x86_64-linux";
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="pci", ATTR{power/control}="auto"
  #   ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  #   ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
  # '';

  security.allowSimultaneousMultithreading = true;

  # services.fwupd.enable = true;
  # hardware.cpu.intel.updateMicrocode = true;

  networking = {
    hostId = "385f9236";
    hostName = "hypernix";
    # useDHCP = false;
    # interfaces.enp3s0.useDHCP = true;
  };

  # services.tlp.enable = true;
  # fileSystems."/" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [ "size=4G" "mode=755" ];
  # };

  # virtualisation.vmVariant.virtualisation.graphics = false;

  # fileSystems."/" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [ "defaults" "size=2G" "mode=755" ];
  # };

  # services.acpid.enable = true;

  # fileSystems."/nix".neededForBoot = true;
  # fileSystems."/persist".neededForBoot = true;
  #
  # environment.persistence."/persist" = {
  #   directories = [
  #     "/etc/nixos"
  #     # "/etc/NetworkManager"
  #     "/var/log"
  #     "/var/lib"
  #     "/home"
  #     "/root"
  #   ];
  #
  #   files = [
  #     "/etc/machine-id"
  #     "/etc/ssh/ssh_host_ed25519_key"
  #     "/etc/ssh/ssh_host_ed25519_key.pub"
  #     "/etc/ssh/ssh_host_rsa_key"
  #     "/etc/ssh/ssh_host_rsa_key.pub"
  #   ];
  #
  #   users.kid = {
  #     directories = [ ".ssh" ];
  #   };
  # };
  #
  # users.users.kid = {
  #   isNormalUser = true;
  #   extraGroup = "kid";
  #   openssh.authorizedKeys.keys = [
  #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCePt+kuDk6ChV7cxo1iBXyA0trZTmhK8YUwwx+UJ2ELYX3fx6kFte68zZ7G5PJ8fclpC5ZKesC/SXGVkfuGq9J+PFekRNF6QlzEz15Sx9eMNYNiBc5KFmeoV6d4BT3ErL6w086cpYXOGvtN/vdsfC5HpO3gZ/RMwrnB9056iiKXECWPvCTG5/6wfaUFW3CcNAJ4o9/uCQD8eAUyKUE+Kadxzd8pasRc1pzN9pBXYMmgrb4H3ICXFHVPkafXevWTdp4Y1X7HoLuqF2T163BtrEjWNnoUL0yJDpukvMQkkHiHWm51u/f4EwXmwzBqRHKFcpeYrWsAM9ymQbrCnBJRy8uyBqnQVzJpsjq2Za+60P4BaeK8mjOIKWS+6/o0Vz4e9mabO2xHkzOI2bECDkOg4ycztPOoNK7LBbfZ060IJv3+td0LeCUphbPxMjKEbjNCWJ7xXdV2r9eHebFfsv6hH381K458ucYTQQN5dc9HrFQdq7CQejwL+sPeJIL/eLHiec= kid@nixos"
  #   ];
  # };


  # environment = {
  #   systemPackages = with pkgs; [
  #     git
  #     tmux
  #     htop
  #     powertop
  #     # cpupower
  #     pciutils # for lspci
  #   ];
  # };

}
