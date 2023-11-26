{
  imports = [
    ../modules/nixos/types/proxmox-vm.nix
    ../modules/nixos/roles-k3s-server.nix
  ];

  nixlab.k3s.enable = true;
}
