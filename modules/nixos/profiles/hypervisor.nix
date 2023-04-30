{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # qemu_full
    # virt-manager
  ];

  # programs.dconf.enable = true;

  # required by libvirtd
  security.polkit.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf.enable = true;
    };
  };
}
