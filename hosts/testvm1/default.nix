{ inputs, config, modulesPath, nixpkgs, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    inputs.impermanence.nixosModule
    ../../modules/common.nix
    inputs.disko.nixosModules.disko
  ];

  boot.loader.systemd-boot.enable = true;
  boot.zfs.devNodes = "/dev/vda2";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  nixpkgs.hostPlatform.system = "x86_64-linux";

  networking = {
    hostId = "385f9236";
    hostName = "testvm1";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  # fileSystems."/" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [ "size=4G" "mode=755" ];
  # };

  virtualisation.vmVariant.virtualisation.graphics = false;

  boot.loader.grub = {
    devices = [ "/dev/vda" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  # fileSystems."/" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [ "defaults" "size=2G" "mode=755" ];
  # };

  disko.devices = {
    disk.vda = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          # {
          #   name = "boot";
          #   type = "partition";
          #   start = "0";
          #   end = "1M";
          #   part-type = "primary";
          #   flags = [ "bios_grub" ];
          # }
          {
            type = "partition";
            name = "ESP";
            start = "1MiB";
            end = "512MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "nixos";
            type = "partition";
            start = "512MiB";
            end = "100%";
            part-type = "primary";
            bootable = true;
            content = {
              type = "zfs";
              pool = "zroot";
            };
          }
        ];
      };
    };

    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=4G"
          "mode=755"
        ];
      };
    };

    zpool = {
      zroot = {
        type = "zpool";

        options = {
          ashift = "12";
          autotrim = "on";
        };

        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          xattr = "sa";
        };

        # mountpoint = "none";

        datasets = {
          nix = {
            zfs_type = "filesystem";
            mountpoint = "/nix";
            mountOptions = [ "zfsutil" ];
          };
          persist = {
            zfs_type = "filesystem";
            mountpoint = "/persist";
            mountOptions = [ "zfsutil" ];
          };
        };
      };
    };
  };

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  # environment.persistence."/persist" = {
  #   directories = [
  #     "/etc/nixos"
  #     "/etc/NetworkManager"
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

}
