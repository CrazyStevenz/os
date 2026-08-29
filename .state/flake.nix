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
      url = "path:/nix/store/8dhbs2f5j8v0n5wwq2hfqvfmfz8p7s16-icedos-config";
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
    icedos-github_icedos_apps = {
      url = "github:icedos/apps/dfe7ec9811868ef212123fff3c3168689c033419";
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
      url = "github:icedos/desktop/434a2504deb85c07eee44b57503ef02f3757726d";
    };
    icedos-github_icedos_desktop-stylix-stylix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/stylix";
    };
    icedos-github_icedos_hardware = {
      url = "github:icedos/hardware/8d3db69a90a3cd5ea90acb56b285e2a78773141b";
    };
    icedos-github_icedos_kde = {
      url = "github:icedos/kde/8ee796d02fa400e8ff0786425a4895249102166c";
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
    icedos-github_icedos_mcp-server = {
      url = "github:icedos/mcp-server/943fb0130448cd09312f9bee61ea98e819fb1754";
    };
    icedos-github_icedos_providers = {
      url = "github:icedos/providers/fe726bf2905c942efefc12bd514c9b4a8207f5fc";
    };
    icedos-github_icedos_providers-jovian-jovian = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:jovian-experiments/jovian-nixos";
    };
    icedos-github_icedos_providers-nur-nur = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/nur";
    };
    icedos-github_icedos_tweaks = {
      url = "github:icedos/tweaks/4ed19e3a4b9dfcefceef29579afebe3cee3d722a";
    };
    icedos-github_icedos_virtualisation = {
      url = "github:icedos/virtualisation/8180dad55d40577893d8a4570c0d9748138e8863";
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
      userConfig = import "${inputs.icedos-core}/lib/load-user-config.nix" "${inputs.icedos-config}";
      inherit (userConfig) icedos;

      icedosLib = import "${inputs.icedos-core}/lib" {
        inherit lib pkgs inputs;
        config = icedos;
        enableLogging = false;
        self = toString inputs.icedos-core;
      };

      inherit (icedosLib) getModules modulesFromConfig;

      # Build-stage re-declaration of `[extraOptions]` options. Re-derived
      # here (not interpolated from the genflake value): the generated flake
      # evaluates against the filtered config snapshot, and the schema must
      # match what this stage reads.
      extraOptionsDeclare = icedosLib.extraOptions.declare (userConfig.extraOptions or { });
    in
    {
      # The module-facing lib as a first-class flake output: the exact
      # value `specialArgs.icedosLib` shares (one `modulesFromConfig`
      # evaluation), so repl-context / MCP `nix_eval` read the same merged
      # lib the module system used.
      icedosLib = modulesFromConfig.closureLib;

      nixosConfigurations.icedos = nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          # Modules see the merged lib: base + every module's top-level
          # `lib` field contribution, merged over the FULLY-RESOLVED
          # closure. Reuses `modulesFromConfig.closureLib` — the exact
          # value the phase-2 module-file/extra-module re-imports were
          # made with — so the module system and the module files share
          # one merged lib and no second `_mergeModuleLibs` fold happens
          # here. The genflake-side uses below keep the base `icedosLib`.
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
              # readOnly: not declared in modules/options.nix, so a
              # config.toml-set value already aborts at genflake with
              # "option does not exist"; readOnly additionally guards
              # module-set values at build stage.
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

          # Loaded module set (derived, read-only): repo base url -> names.
          # Computed by modulesFromConfig from the raw icedos config, so no
          # circular dependency on the evaluated config. Backs
          # `icedosLib.hasModule`.
          {
            icedos.system.loadedModules = modulesFromConfig.loadedModules;
          }

          {
            imports = getModules "${inputs.icedos-core}/modules";
          }

          # Extra modules and stateVersion. Each configured extra-module
          # directory (default `modules`) is scanned and imported; missing
          # ones are skipped.
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

          # Raw NixOS config passthrough: every top-level table in
          # config.toml / configs/*.toml *except* [icedos.*] is applied verbatim
          # as NixOS config. nixpkgs' module system types & validates each option —
          # IceDOS declares no schema. (home-manager is reachable the usual way,
          # under [home-manager.users.<name>.*].) The `extraOptions` table is a
          # declaration schema, not values, so it is excluded here (its options are
          # declared by `extraOptionsDeclare` below).
          (lib.setDefaultModuleLocation "config.toml / configs/*.toml (raw NixOS passthrough)" {
            config = builtins.removeAttrs userConfig [
              "icedos"
              "extraOptions"
            ];
          })

          extraOptionsDeclare

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
