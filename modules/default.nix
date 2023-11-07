{ config, ... }:
{
  flake.nixosModules = config.flake.lib.importFilesToAttrs ./nixos [
    "common"
    "profiles-server"
    "profiles-hypervisor"
    "roles-k3s-server"
    "roles-syslog"
    "roles-printing"
  ];
}
