let
  authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCePt+kuDk6ChV7cxo1iBXyA0trZTmhK8YUwwx+UJ2ELYX3fx6kFte68zZ7G5PJ8fclpC5ZKesC/SXGVkfuGq9J+PFekRNF6QlzEz15Sx9eMNYNiBc5KFmeoV6d4BT3ErL6w086cpYXOGvtN/vdsfC5HpO3gZ/RMwrnB9056iiKXECWPvCTG5/6wfaUFW3CcNAJ4o9/uCQD8eAUyKUE+Kadxzd8pasRc1pzN9pBXYMmgrb4H3ICXFHVPkafXevWTdp4Y1X7HoLuqF2T163BtrEjWNnoUL0yJDpukvMQkkHiHWm51u/f4EwXmwzBqRHKFcpeYrWsAM9ymQbrCnBJRy8uyBqnQVzJpsjq2Za+60P4BaeK8mjOIKWS+6/o0Vz4e9mabO2xHkzOI2bECDkOg4ycztPOoNK7LBbfZ060IJv3+td0LeCUphbPxMjKEbjNCWJ7xXdV2r9eHebFfsv6hH381K458ucYTQQN5dc9HrFQdq7CQejwL+sPeJIL/eLHiec= kid@nixos"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClpcMnFaSg8vLGZvy2gP+/hJlT2rF2bkmJFYJTYt4pKjzhiCWVgG8LO0WCGk1+w/PexHsV6q3So3zd4EivxT52f+8mdidp6HBAZ/4eN8vU1CvjiyTYr33gFT4fZ61rQL9xHss8Uw1pZysfBwJGpY1tvXg0kD2Bq2pOuK7ZUxirTBjVdksRLIoxU+Ogsv3qxORfDN3k2+x/FKtmB9G+L0o9Ak7WEb765I8gptv3Qr7eRgtU7CgLrV56ByxIV+0+Hi9DTJ1A6ITIk+9IrpSXH/PeJsJLZNl2lQXPqvfZFVgBp9W75D9zZiOLWWxS4jqHc5qMGiToCf9wyr0RpixTWZjRRHoG1Wef5IA0yvdQVPMPPI7b6DXjzzdJAKsBekY5WybxvUWDF+jJsEy7pKPY8xg1co1PTlgYVJw29cd6bQ7NrxmOlJ7znHK2fXw5zFz2S7ZrTK2qOBllygkRkaa79kMBhsOiic27JII6QLaV84+o2DtG4vaN1qGln0kNQ8md9jk= kid@lenovo"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmCXB1xR8Eo0g1eiRpHSrpNkIw4eCwFph/k9wnn5iGHwqpU0hPutidBQgYrbOxkVwTf22s13KPGqrtT15BCzvngjit4KO494HsNjwOJlUgQNOIA4jkulXZUoL4zPRJtfkW8nYsoGW+3aNlVhkolY3Ry76mijHCUIsg+vwl7x2pFB/JxbMjcXDra1pdCGV5A6RsRXX2VYtPb2Cp7v3FEAuEynH71BX70IUMLMPG2xGer4a+u7/2Onu1jGXZIG85Z8sPUKaurue6/Vo2nCM2qH+gXqHt0inMG2WBSa14OTd4Q2KgtjQP9dt+BYkL9d5UK0jhoYX6/Lr1bVYYYSIPuJ8dtEqGHm4yKuh+J71eGXv244LYZKgRbk902KnSH8h6dUFhCgSd/YIOgwGkByfkIeIKbeyWqjQAv67NhOcN5fsuzvvPvzMen1ykaW6grjoNncZCjD55vUdt462C3tdr0N+D4wxvZw96twbnO7koljq7qqVMcWs8r/6klJoIIa02im8= kid@Arnauds-MacBook-Pro"
  ];
in
{
  security.sudo.wheelNeedsPassword = false;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    autosuggestions.async = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship.enable = true;

  users = {
    mutableUsers = false;
    # defaultUserShell = pkgs.zsh;

    users.kid = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" ];
      hashedPassword = "$y$j9T$B2xElbeD8FoE.y/zrItkk0$TLLFGXW/4LTQe0CqXbQ7YDE6xBr0ZqrJcn8gZPgzqY8";
      createHome = true;
      # shell = pkgs.zsh;
      openssh.authorizedKeys.keys = authorizedKeys;
    };

    users.root = {
      openssh.authorizedKeys.keys = authorizedKeys;
    };
  };
}
