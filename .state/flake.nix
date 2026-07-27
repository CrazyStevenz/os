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
      url = "path:/nix/store/3sbb3qbi29k3pb83vv64zvlbfay4dlv1-icedos-config";
    };
    icedos-core = {
      follows = "icedos-config/icedos";
    };
    icedos-github_icedos_apps = {
      url = "github:icedos/apps/5e9f81d41da4c1beef8e8b319ab7b0ac4936a8c0";
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
      url = "github:icedos/desktop/c39d812a526458a0fbc5e51bc2bcb49eaed9fc2d";
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
      url = "github:icedos/hardware/a6b80470161b089ef51c7efd55ff1e6036d8632c";
    };
    icedos-github_icedos_kde = {
      url = "github:icedos/kde/a4e0614afb823e0bd802217a065c17615575439c";
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
      url = "github:icedos/providers/38af861c05150dc492dde0128be6941b8d648d75";
    };
    icedos-github_icedos_tweaks = {
      url = "github:icedos/tweaks/14f09b7e4a52e264705e17aeb8169ef2f7d9abf2";
    };
    icedos-github_icedos_virtualisation = {
      url = "github:icedos/virtualisation/def37d04cf2d5044e67e7f43f3893845a5607cbc";
    };
    icedos-overlay-github_nixos_nixpkgs_nixos-unstable-small = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
    };
    icedos-state = {
      flake = false;
      url = "path:/nix/store/ry8ci5bv3l5yiic93hcw4w8zpmqc98b9-icedos";
    };
    jovian = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:jovian-experiments/jovian-nixos";
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
      userConfig = import "${inputs.icedos-core}/lib/load-user-config.nix" "${inputs.icedos-config}";
      inherit (userConfig) icedos;

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
          # under [home-manager.users.<name>.*].)
          (lib.setDefaultModuleLocation "config.toml / configs/*.toml (raw NixOS passthrough)" {
            config = builtins.removeAttrs userConfig [ "icedos" ];
          })

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
