{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

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
      "pcie_aspm=force"
      "intel_pstate=passive"
      "nvme.noacpi=1"
      "memsleep_default=deep"
    ];
  };

  disko.devices = import ./disk-config.nix { inherit lib; };
  virtualisation.vmVariant = {
    virtualisation.graphics = false;
    virtualisation.useDefaultFilesystems = false;
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  # hardware.enableRedistributableFirmware = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
    scsiLinkPolicy = "med_power_with_dipm";
  };
}
