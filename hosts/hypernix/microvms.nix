{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.microvm.overlay
  ];

  microvm = {
    # declarativeUpdates = true;
    # restartIfChanged = true;
    # vms.microvm1 = {
    #   flake = self;
    # };
    vms.microvm2.config = {
      imports = [
        ../../modules/common.nix
        inputs.microvm.nixosModules.microvm
        ({ pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            htop
          ];
        })
      ];
      # nixpkgs.hostPlatform.system = "x86_64-linux";
      networking.hostName = "microvm2";
      services.openssh.enable = true;
      microvm = {
        shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
        ];
        # writableStoreOverlay = "/nix/.rw-store";
        hypervisor = "qemu";
        interfaces = [
          {
            id = "eth0";
            type = "bridge";
            bridge = "br100";
            mac = "58:DB:A7:29:A4:46";
          }
        ];
      };
    };

    autostart = [
      # "microvm1"
      "microvm2"
    ];
  };
}
