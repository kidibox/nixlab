{ config, lib, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    initrd.supportedFilesystems = [ "zfs" ];

    zfs.enableUnstable = true;
    zfs.devNodes = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_22518J459213-part2";

    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # kernelPackages = pkgs.linuxPackages_latest_hardened;

    kernelParams = [
      # "pcie_aspm=force"
      # "intel_pstate=active"
      "intel_pstate=no_hwp"
      "nvme.noacpi=1"
      # "memsleep_default=deep"
    ];
  };

  disko.devices = import ./disk-config.nix { inherit lib; };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
    scsiLinkPolicy = "med_power_with_dipm";
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  services = {
    fwupd.enable = true;
    smartd.enable = true;
    thermald.enable = true;
  };

  hardware.bluetooth.enable = false;
}
