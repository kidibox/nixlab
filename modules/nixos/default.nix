{ self, lib, ... }:
let
  inherit (builtins)
    listToAttrs
    replaceStrings
    stringLength
    substring
    ;

  exposeModules = baseDir: paths:
    let
      prefix = stringLength (toString baseDir) + 1;
      toPair = path:
        {
          name = replaceStrings [ "/" ] [ "-" ] (replaceStrings [ ".nix" ] [ "" ] (substring prefix 1000000 (toString path)));
          value = path;
        };
    in
    listToAttrs
      (map toPair paths)
  ;
in
# exposeModules ./.
  #   ((lib.filesystem.listFilesRecursive ./mixins)
  #     ++
  #     (lib.filesystem.listFilesRecursive ./profiles)
  #   )
exposeModules ./. [
  ./mixins/base/users
  ./mixins/common/networking.nix
  ./mixins/nix.nix
  ./mixins/impermanence.nix
  ./profiles/server.nix
  ./profiles/hypervisor.nix
]
