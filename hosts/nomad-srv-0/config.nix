{ config, lib, ... }:
{
  modules = [{
    imports = lib.lists.flatten [
      # ../../modules/nixos/profiles-microvm.nix
      (builtins.attrValues {
        inherit (config.flake.nixosModules)
          profiles-microvm
          ;
      })
      {
        networking.hostName = "nomad-srv-0";
      }
      {
        microvm = {
          interfaces = [
            {
              id = "eth0";
              type = "bridge";
              bridge = "br100";
              mac = "58:DB:A7:29:A4:46";
            }
          ];
        };
      }
    ];
  }];
}
