{ withSystem, config, inputs, lib, ... }: {
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    let
      hostName = "nomad-srv-1";
    in
    {
      nixosConfigurations.${hostName} =
        let
          specialArgs = { inherit inputs; };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system specialArgs;

          modules = lib.lists.flatten [
            (builtins.attrValues {
              inherit (config.flake.nixosModules)
                profiles-microvm
                ;
            })
            {
              networking.hostName = hostName;
            }
            {
              microvm = {
                interfaces = [
                  {
                    id = "eth0";
                    type = "bridge";
                    bridge = "br100";
                    mac = "58:DB:A7:29:A4:47";
                  }
                ];
              };
            }
          ];
        };
    }
  );
}
