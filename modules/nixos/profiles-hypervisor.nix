{ pkgs, ... }:
{
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  # required by libvirtd
  security.polkit.enable = true;

  # FIXME figure out why it's not booting
  # virtualisation.kvmgt.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf.enable = true;
    };
    allowedBridges = [ "br10" "br100" ];
    onShutdown = "shutdown";
  };
}
