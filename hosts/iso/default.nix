{ pkgs, config, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    # "${modulesPath}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  system.stateVersion = "22.11";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Enable SSH in the boot process.
  # systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCePt+kuDk6ChV7cxo1iBXyA0trZTmhK8YUwwx+UJ2ELYX3fx6kFte68zZ7G5PJ8fclpC5ZKesC/SXGVkfuGq9J+PFekRNF6QlzEz15Sx9eMNYNiBc5KFmeoV6d4BT3ErL6w086cpYXOGvtN/vdsfC5HpO3gZ/RMwrnB9056iiKXECWPvCTG5/6wfaUFW3CcNAJ4o9/uCQD8eAUyKUE+Kadxzd8pasRc1pzN9pBXYMmgrb4H3ICXFHVPkafXevWTdp4Y1X7HoLuqF2T163BtrEjWNnoUL0yJDpukvMQkkHiHWm51u/f4EwXmwzBqRHKFcpeYrWsAM9ymQbrCnBJRy8uyBqnQVzJpsjq2Za+60P4BaeK8mjOIKWS+6/o0Vz4e9mabO2xHkzOI2bECDkOg4ycztPOoNK7LBbfZ060IJv3+td0LeCUphbPxMjKEbjNCWJ7xXdV2r9eHebFfsv6hH381K458ucYTQQN5dc9HrFQdq7CQejwL+sPeJIL/eLHiec= kid@nixos"
  ];

  powerManagement.powertop.enable = true;


  environment = {
    systemPackages = with pkgs; [
      git
      tmux
      htop
      powertop
      # cpupower
    ];
  };

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
