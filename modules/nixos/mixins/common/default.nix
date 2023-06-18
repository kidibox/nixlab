{
  imports = [
    ./users.nix
    ./nix.nix
    ./networking.nix
    ./sops.nix
  ];

  time.timeZone = "Europe/Brussels";
}
