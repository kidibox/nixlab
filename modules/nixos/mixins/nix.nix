{
  nix = {
    settings = {
      allowed-users = [ "root" "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
  };
}
