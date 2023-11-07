{ modulesPath, inputs, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/minimal.nix"
    ../../modules/nixos/mixins/common/networking.nix
    ../../modules/nixos/mixins/common/nix.nix
    ../../modules/nixos/mixins/common/users.nix

    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot

    ./disk-config.nix
  ];
  # })

  # (builtins.attrValues {
  #   inherit (inputs.nixos-hardware.nixosModules)
  #     common-pc
  #     common-pc-ssd
  #     common-cpu-intel
  #     ;
  #
  #   inherit (config.flake.nixosModules)
  #     profiles-server
  #     profiles-hypervisor
  #     roles-syslog
  #     roles-printing
  #     roles-k3s-server
  #     ;
  # })

  # proxmox.qemuConf.bios = "ovmf";
  # boot.loader.timeout = lib.mkForce 0;
  networking = {
    # inherit hostName;

    useDHCP = true;
  };

  # fileSystems."/" = {
  #   device = "/dev/vda1";
  #   fsType = "ext4";
  # };
  #

  boot.kernelParams = [ "console=tty0" ];

  services.qemuGuest.enable = true;
}
