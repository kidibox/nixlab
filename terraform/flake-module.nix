{
  perSystem = { pkgs, ... }: {
    devShells.terraform = pkgs.mkShell {
      buildInputs = with pkgs; [
        sops
        terragrunt
        (terraform.withPlugins (p: [
          p.sops
        ]))
      ];
    };
  };
}
