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
      url = "path:/nix/store/3lfqg16l79zlb2zbyzajwcjzppml9c56-icedos-config";
    };
    icedos-config-hytale-launcher = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/xivv2i5253l6j04il7c5l23x8pgbv63x-icedos-config-hytale-launcher-subflake";
    };
    icedos-core = {
      follows = "icedos-config/icedos";
    };
    icedos-github_icedos_apps = {
      url = "github:icedos/apps/ba4ac9154fa2f199efb0b8097b1b1ff6988dac71";
    };
    icedos-github_icedos_apps-aagl = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/26rhnp7s04952clqh6f1gqrbz0fyhas6-icedos-github_icedos_apps-aagl-subflake";
    };
    icedos-github_icedos_apps-celluloid = {
      inputs = { };
      url = "path:/nix/store/bakwi8d6hcgmmjnmrrr4nzvwjhwsbcix-icedos-github_icedos_apps-celluloid-subflake";
    };
    icedos-github_icedos_apps-proton-launch = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/yihk6z7bd9rh3zyfgc8b1w0vq28gkznb-icedos-github_icedos_apps-proton-launch-subflake";
    };
    icedos-github_icedos_desktop = {
      url = "github:icedos/desktop/434a2504deb85c07eee44b57503ef02f3757726d";
    };
    icedos-github_icedos_desktop-stylix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/crb5iyljvk4kh2mf3bnb9a21v4l8jvbg-icedos-github_icedos_desktop-stylix-subflake";
    };
    icedos-github_icedos_hardware = {
      url = "github:icedos/hardware/2d96776cbd686c5971dfc900a02f8e1b4f0486ec";
    };
    icedos-github_icedos_kde = {
      url = "github:icedos/kde/04c0ac1c0e662a9ac9b66aedeb25ef5843f01366";
    };
    icedos-github_icedos_kde-default = {
      inputs = {
        home-manager = {
          follows = "home-manager";
        };
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/7aczmhzngbc9q0dx2mfb2apjvbq0hdhw-icedos-github_icedos_kde-default-subflake";
    };
    icedos-github_icedos_mcp-server = {
      url = "github:icedos/mcp-server/943fb0130448cd09312f9bee61ea98e819fb1754";
    };
    icedos-github_icedos_providers = {
      url = "github:icedos/providers/5d7e31dc0d66939b2bf0525434fab1d1a95e35cd";
    };
    icedos-github_icedos_providers-jovian = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/m4dv6ndsd7kadj61d6f2i3j8a0bm21zz-icedos-github_icedos_providers-jovian-subflake";
    };
    icedos-github_icedos_providers-nur = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "path:/nix/store/c4kbdm8j9zl9vl23mgclszb7cki87n36-icedos-github_icedos_providers-nur-subflake";
    };
    icedos-github_icedos_tweaks = {
      url = "github:icedos/tweaks/73d7d42457bb2b86e63f2da06575f3b51e4b5a8c";
    };
    icedos-github_icedos_virtualisation = {
      url = "github:icedos/virtualisation/f7cdb7e73347210e165d3e0d0bcd9c31d302ac07";
    };
    icedos-overlay-github_nixos_nixpkgs_nixos-unstable-small = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
    };
    icedos-state = {
      flake = false;
      url = "path:/nix/store/yw05v41gq3nsv7jm2g5194n3471qan5b-icedos";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
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
      userConfig = import "${inputs.icedos-core}/lib/config/load-user-config.nix" "${inputs.icedos-config
      }";
      inherit (userConfig) icedos;

      icedosLib = import "${inputs.icedos-core}/lib" {
        inherit lib pkgs inputs;
        config = icedos;
        enableLogging = false;
        self = toString inputs.icedos-core;
      };

      inherit (icedosLib) getModules modulesFromConfig;

      # Re-derived, not interpolated: this stage reads the filtered snapshot.
      extraOptionsDeclare = icedosLib.extraOptions.declare (userConfig.extraOptions or { });
    in
    {
      # The same value `specialArgs.icedosLib` gets, so repl-context and MCP
      # `nix_eval` read the lib the module system actually used.
      icedosLib = modulesFromConfig.closureLib;

      nixosConfigurations.icedos = nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          # Reused (not re-merged), so module files and the module system share
          # one lib. Genflake-side uses below keep the base `icedosLib`.
          icedosLib = modulesFromConfig.closureLib;
          inherit inputs;
        };

        modules = [
          # Read configuration location
          (
            { icedosLib, ... }:
            let
              inherit (icedosLib) mkStrOption;
            in
            {
              # config.toml values already abort at genflake ("option does not
              # exist"); readOnly guards module-set values at build stage.
              options.icedos.configurationLocation = mkStrOption {
                readOnly = true;
                default = "/home/stef/code/os/.state";
              };
            }
          )

          # Remove nixos manual package
          {
            documentation.nixos.enable = false;
          }

          # repo url -> names, computed from the RAW config (no circularity).
          # Backs `icedosLib.hasModule`.
          {
            icedos.system.loadedModules = modulesFromConfig.loadedModules;
          }

          {
            imports = getModules "${inputs.icedos-core}/modules";
          }

          # Extra modules and stateVersion; missing dirs are skipped.
          {
            imports = lib.flatten (
              map (
                d:
                let
                  p = "${inputs.icedos-config}/${d}";
                in
                if pathExists p then getModules p else [ ]
              ) [ "modules" ]
            );
            config.system.stateVersion = "23.05";
          }

          # Every top-level table except [icedos.*] is applied verbatim as NixOS
          # config; `extraOptions` is a schema, not values, so it is excluded.
          (lib.setDefaultModuleLocation "config.toml / configs/*.toml (raw NixOS passthrough)" {
            config = builtins.removeAttrs userConfig [
              "icedos"
              "extraOptions"
            ];
          })

          extraOptionsDeclare

          home-manager.nixosModules.home-manager

          ({ config, lib, ... }: {
            # Head of the list, so the source swap runs BEFORE downstream
            # `overrideAttrs` patch overlays it would otherwise clobber.
            nixpkgs.overlays = lib.mkBefore (
              icedosLib.pkgs.overlaysFromChannel config.icedos
                inputs."icedos-overlay-github_nixos_nixpkgs_nixos-unstable-small"
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
