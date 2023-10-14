{ config, ... }:
{
  flake.nixosModules = config.flake.lib.importFilesToAttrs ./nixos [
    "common"
    "profiles-server"
    "profiles-hypervisor"
    "profiles-microvm"
    "roles-syslog"
    "roles-printing"
  ];
}
