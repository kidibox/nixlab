# { lib, disks ? [ "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_22518J459213" ], ... }: {
{ lib, disks ? [ "/dev/vda" ], ... }: {
  disk = lib.genAttrs disks (dev: {
    device = dev;
    type = "disk";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
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
  });

  nodev = {
    "/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=2G"
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
}
