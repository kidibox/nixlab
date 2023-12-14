{
  imports = [
    ../modules/nixos/mixins/common/sops.nix
    ../modules/nixos/types/proxmox-vm.nix
    ../modules/nixos/roles-cloudflared.nix
  ];
}
