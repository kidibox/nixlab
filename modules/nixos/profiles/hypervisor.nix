{ pkgs, ... }:
{
  # required by libvirtd
  security.polkit.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf.enable = true;
    };
    allowedBridges = [ "br10" "br100" ];
  };
}
