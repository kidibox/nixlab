{ self, inputs, lib, ... }:
let
  specialArgs = { inherit inputs self; };

  items = builtins.removeAttrs (builtins.readDir (./.)) [
    "default.nix"
    # We don't need a nixos config for it
    # "installer.nix"
  ];

  build = (path:
    let
      hostName = builtins.replaceStrings [ ".nix" ] [ "" ] path;
    in
    {
      name = hostName;
      value = inputs.nixpkgs.lib.nixosSystem
        {
          inherit specialArgs;

          modules = [
            inputs.disko.nixosModules.disko
            {
              imports = [ ./${path} ];

              nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

              networking = {
                inherit hostName;
              };
            }
          ];
        };
    });
in
{
  flake.nixosConfigurations = builtins.listToAttrs (builtins.map build (builtins.attrNames items));
}
