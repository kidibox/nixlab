{
  system.stateVersion = "23.05";

  users.users.kid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    hashedPassword = "$y$j9T$B2xElbeD8FoE.y/zrItkk0$TLLFGXW/4LTQe0CqXbQ7YDE6xBr0ZqrJcn8gZPgzqY8";
    createHome = true;
    # shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCePt+kuDk6ChV7cxo1iBXyA0trZTmhK8YUwwx+UJ2ELYX3fx6kFte68zZ7G5PJ8fclpC5ZKesC/SXGVkfuGq9J+PFekRNF6QlzEz15Sx9eMNYNiBc5KFmeoV6d4BT3ErL6w086cpYXOGvtN/vdsfC5HpO3gZ/RMwrnB9056iiKXECWPvCTG5/6wfaUFW3CcNAJ4o9/uCQD8eAUyKUE+Kadxzd8pasRc1pzN9pBXYMmgrb4H3ICXFHVPkafXevWTdp4Y1X7HoLuqF2T163BtrEjWNnoUL0yJDpukvMQkkHiHWm51u/f4EwXmwzBqRHKFcpeYrWsAM9ymQbrCnBJRy8uyBqnQVzJpsjq2Za+60P4BaeK8mjOIKWS+6/o0Vz4e9mabO2xHkzOI2bECDkOg4ycztPOoNK7LBbfZ060IJv3+td0LeCUphbPxMjKEbjNCWJ7xXdV2r9eHebFfsv6hH381K458ucYTQQN5dc9HrFQdq7CQejwL+sPeJIL/eLHiec= kid@nixos"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCePt+kuDk6ChV7cxo1iBXyA0trZTmhK8YUwwx+UJ2ELYX3fx6kFte68zZ7G5PJ8fclpC5ZKesC/SXGVkfuGq9J+PFekRNF6QlzEz15Sx9eMNYNiBc5KFmeoV6d4BT3ErL6w086cpYXOGvtN/vdsfC5HpO3gZ/RMwrnB9056iiKXECWPvCTG5/6wfaUFW3CcNAJ4o9/uCQD8eAUyKUE+Kadxzd8pasRc1pzN9pBXYMmgrb4H3ICXFHVPkafXevWTdp4Y1X7HoLuqF2T163BtrEjWNnoUL0yJDpukvMQkkHiHWm51u/f4EwXmwzBqRHKFcpeYrWsAM9ymQbrCnBJRy8uyBqnQVzJpsjq2Za+60P4BaeK8mjOIKWS+6/o0Vz4e9mabO2xHkzOI2bECDkOg4ycztPOoNK7LBbfZ060IJv3+td0LeCUphbPxMjKEbjNCWJ7xXdV2r9eHebFfsv6hH381K458ucYTQQN5dc9HrFQdq7CQejwL+sPeJIL/eLHiec= kid@nixos"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # services.openssh.enable = true;
  # networking.firewall.enable = true;

  nix.settings.allowed-users = [ "@wheel" ];
}
