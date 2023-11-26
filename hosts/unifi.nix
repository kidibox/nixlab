{
  imports = [
    ../modules/nixos/types/proxmox-vm.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.unifi = {
    enable = true;
    # Oen ports for service discovery & firmware upgrades
    openFirewall = true;
  };

  # Allow access to the portal
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
