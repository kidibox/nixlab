{ inputs, ... }:
{
  imports = [
    inputs.impermanence.nixosModule
  ];

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  # fileSystems."/persist/home".neededForBoot = true;

  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/etc/rancher"
      "/var/log"
      "/var/lib"
      # "/var/cache/powertop"
      # "/home"
      # "/root"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    users.kid.directories = [ "/" ];
  };
}
