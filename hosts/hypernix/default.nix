{ self, inputs, lib, pkgs, config, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/minimal.nix"
    inputs.impermanence.nixosModule
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';

  # TODO move this to common
  # TODO is this even required?
  # services.fwupd.enable = true;
  # hardware.cpu.intel.updateMicrocode = true;

  networking = {
    # required by ZFS
    hostId = "385f9236";
    hostName = "hypernix";
  };
}
