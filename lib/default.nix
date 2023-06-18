{ lib, ... }:
{
  flake.lib = {
    importFilesToAttrs = basePath: files:
      builtins.listToAttrs (map
        (name: lib.nameValuePair name (
          let
            file = basePath + "/${name}.nix";
            folder = basePath + "/${name}";
          in
          if builtins.pathExists file then file else folder
        ))
        files
      );
  };
}
