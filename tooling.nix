{
  perSystem = { config, pkgs, inputs', ... }: {
    devshells.default = {
      packages = with pkgs; [
        nil
        rnix-lsp
        treefmt
        terragrunt
        terraform
        terraform-ls
        nodePackages.cdktf-cli
        deploy-rs
        sops
        age
        ssh-to-age
        cilium-cli
        hubble
        fluxcd
        postgresql
        inputs'.dagger.packages.dagger
      ];
    };

    treefmt.config = {
      projectRootFile = "flake.nix";
      package = pkgs.treefmt;

      programs = {
        nixpkgs-fmt.enable = true;
        deadnix.enable = true;
        terraform.enable = true;
        prettier = {
          enable = true;
          excludes = [
            "kubernetes/flux/flux-system/*.yaml"
            "*.sops.yaml"
          ];
        };
      };
    };
  };
}
