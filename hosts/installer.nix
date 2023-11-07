{ inputs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ../modules/nixos/mixins/common/nix.nix
    ../modules/nixos/mixins/common/users.nix
    inputs.nixos-generators.nixosModules.all-formats
  ];

  services.qemuGuest.enable = true;
}
