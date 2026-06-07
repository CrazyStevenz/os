{
  inputs = {
    home-manager = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/home-manager";
    };
    icedos-config = {
      url = "path:/nix/store/s05llcwravrzkicqwlszzhmq0pc89j8n-icedos-config";
    };
    icedos-config-hytale-launcher-hytale-launcher = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:JPyke3/hytale-launcher-nix";
    };
    icedos-core = {
      follows = "icedos-config/icedos";
    };
    icedos-github_icedborn_claude-icedos = {
      url = "github:icedborn/claude-icedos/3872b8136f5c33748b9cc7fa8d6ef2a82a6bab75";
    };
    icedos-github_icedborn_claude-icedos-peon-ping-peon-ping = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:PeonPing/peon-ping";
    };
    icedos-github_icedos_apps = {
      url = "github:icedos/apps/de8b64e836985a978dc03df4f02356b150d7e43e";
    };
    icedos-github_icedos_apps-aagl-aagl = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:ezKEa/aagl-gtk-on-nix";
    };
    icedos-github_icedos_apps-celluloid-celluloid-shader = {
      flake = false;
      url = "path:///nix/store/5zcj323fgw0vxx0nhgvp45yxrwikm0c6-FSR.glsl";
    };
    icedos-github_icedos_apps-proton-launch-scopebuddy = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:HikariKnight/ScopeBuddy";
    };
    icedos-github_icedos_desktop = {
      url = "github:icedos/desktop/0c2b4034e73fc37671de4ea4eef9e5d183dee450";
    };
    icedos-github_icedos_desktop-stylix-stylix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/stylix";
    };
    icedos-github_icedos_gnome = {
      url = "github:icedos/gnome/936bf0d745c62bcc00777910d86b4a94ab7addb5";
    };
    icedos-github_icedos_hardware = {
      url = "github:icedos/hardware/a268f31077ffe2b2d0645721ccd174336e1d53d2";
    };
    icedos-github_icedos_kde = {
      url = "github:icedos/kde/bb36c2a3aa2ee02ab3594d957d627a4826ff0468";
    };
    icedos-github_icedos_kde-default-plasma-manager = {
      inputs = {
        home-manager = {
          follows = "home-manager";
        };
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/plasma-manager";
    };
    icedos-github_icedos_providers = {
      url = "github:icedos/providers/c1a5aa2f9cdfd58f0c58ea78a4905c6afa9c373e";
    };
    icedos-github_icedos_tweaks = {
      url = "github:icedos/tweaks/13a2a6c4a6bac229b5a980398c70c54783ff2845";
    };
    icedos-overlay-github_K900_nixpkgs_788a6c3a28b78c647ceb5c69d9346845985df77b = {
      url = "github:K900/nixpkgs/788a6c3a28b78c647ceb5c69d9346845985df77b";
    };
    icedos-state = {
      flake = false;
      url = "path:/nix/store/2szh47a70xy566yfg2rf010ic53k90ai-icedos";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nur = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/nur";
    };
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ ];
        };
      };

      inherit (pkgs) lib;
      inherit (builtins) pathExists;
      inherit (import "${inputs.icedos-core}/lib/load-user-config.nix" "${inputs.icedos-config}") icedos;

      icedosLib = import "${inputs.icedos-core}/lib" {
        inherit lib pkgs inputs;
        config = icedos;
        self = toString inputs.icedos-core;
      };

      inherit (icedosLib) getModules modulesFromConfig;
    in
    {
      nixosConfigurations."icedos" = nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          inherit icedosLib inputs;
        };

        modules = [
          # Read configuration location
          (
            { icedosLib, ... }:
            let
              inherit (icedosLib) mkStrOption;
            in
            {
              options.icedos.configurationLocation = mkStrOption {
                default = "/home/stef/code/os/.state";
              };
            }
          )

          # Remove nixos manual package
          {
            documentation.nixos.enable = false;
          }

          {
            imports = getModules "${inputs.icedos-core}/modules";
          }

          # Extra modules and stateVersion
          {
            imports =
              if (pathExists "${inputs.icedos-config}/extra-modules") then
                (getModules "${inputs.icedos-config}/extra-modules")
              else
                [ ];
            config.system.stateVersion = "23.05";
          }

          home-manager.nixosModules.home-manager

          ({ config, lib, ... }: {
            # `lib.mkBefore` keeps these overlays at the head of
            # `nixpkgs.overlays` so they swap the package source
            # *before* downstream patch overlays (e.g. cosmic
            # patches) run via `prev.<pkg>.overrideAttrs`. Without
            # it the swap clobbers patches that already landed on
            # the base derivation.
            nixpkgs.overlays = lib.mkBefore (
              icedosLib.pkgs.overlaysFromChannel config.icedos
                inputs."icedos-overlay-github_K900_nixpkgs_788a6c3a28b78c647ceb5c69d9346845985df77b"
                [ "kdePackages" ]
            );
          })

          { icedos.system.isFirstBuild = true; }

          (
            # Do not modify this file!  It was generated by ‘nixos-generate-config’
            # and may be overwritten by future invocations.  Please make changes
            # to /etc/nixos/configuration.nix instead.
            {
              config,
              lib,
              pkgs,
              modulesPath,
              ...
            }:

            {
              imports = [
                (modulesPath + "/installer/scan/not-detected.nix")
              ];

              boot.initrd.availableKernelModules = [
                "nvme"
                "xhci_pci"
                "ahci"
                "usbhid"
                "usb_storage"
                "sd_mod"
              ];
              boot.initrd.kernelModules = [ ];
              boot.kernelModules = [ "kvm-amd" ];
              boot.extraModulePackages = [ ];

              fileSystems."/" = {
                device = "/dev/disk/by-uuid/875ba1fd-ae85-47ec-beac-ec515e776834";
                fsType = "btrfs";
                options = [ "subvol=@" ];
              };

              boot.initrd.luks.devices."luks-a42d4af1-e764-4d91-acb2-ac735d979a64".device =
                "/dev/disk/by-uuid/a42d4af1-e764-4d91-acb2-ac735d979a64";

              fileSystems."/boot" = {
                device = "/dev/disk/by-uuid/080E-B189";
                fsType = "vfat";
              };

              swapDevices = [ ];

              # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
              # (the default) this is the recommended approach. When using systemd-networkd it's
              # still possible to use this option, but it's recommended to use it in conjunction
              # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
              networking.useDHCP = lib.mkDefault true;
              # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

              nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
              hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
            }
          )

        ]
        ++ modulesFromConfig.options
        ++ (modulesFromConfig.nixosModules { inherit inputs; });
      };
    };
}
