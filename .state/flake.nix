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
      url = "path:/home/stef/code/os";
    };
    icedos-core = {
      follows = "icedos-config/icedos";
    };
    icedos-github_icedos_apps = {
      url = "github:icedos/apps/e8f811afaf901426db2be6012f8e4fe10ad4b415";
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
    icedos-github_icedos_apps-flatpak-nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
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
      url = "github:icedos/desktop/7966dbc9c2316a46bc7748d025fd4db098b0d2fa";
    };
    icedos-github_icedos_gnome = {
      url = "github:icedos/gnome/361f1e01ec385848546f5b2c9ae741c42a137b28";
    };
    icedos-github_icedos_hardware = {
      url = "github:icedos/hardware/2811c2ddedfc768c08b2d4b2f215fe7bb35d1fb6";
    };
    icedos-github_icedos_providers = {
      url = "github:icedos/providers/c1a5aa2f9cdfd58f0c58ea78a4905c6afa9c373e";
    };
    icedos-github_icedos_tweaks = {
      url = "github:icedos/tweaks/0735682a601229bd5ad9b874f147fdd7c129918f";
    };
    icedos-path__home_stef_code_os__repos_hytale-launcher = {
      url = "path:/home/stef/code/os/.repos/hytale-launcher?narHash=sha256-oYwGh6ZO1uCzhQ/+BUk/FDcuNenulk9pNW3b5vsn0TA=";
    };
    icedos-path__home_stef_code_os__repos_hytale-launcher-default-hytale-launcher = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:JPyke3/hytale-launcher-nix";
    };
    icedos-state = {
      flake = false;
      url = "path:/nix/store/yw05v41gq3nsv7jm2g5194n3471qan5b-icedos";
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

          permittedInsecurePackages = [

          ];
        };
      };

      inherit (pkgs) lib;
      inherit (lib) fileContents filterAttrs;

      inherit (builtins) pathExists;
      inherit ((fromTOML (fileContents "${inputs.icedos-config}/config.toml"))) icedos;

      icedosLib = import "${inputs.icedos-core}/lib" {
        inherit lib pkgs inputs;
        config = icedos;
        self = toString inputs.icedos-core;
      };

      inherit (icedosLib) modulesFromConfig;

      getModules =
        path:
        map (dir: "/${path}/${dir}") (
          let
            inherit (lib) attrNames;
          in
          attrNames (filterAttrs (n: v: v == "directory") (builtins.readDir path))
        );
    in
    {
      nixosConfigurations."icedos" = nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          inherit icedosLib inputs;
        };

        modules = [
          # Read configuration location
          (
            { lib, ... }:
            let
              inherit (lib) mkOption types;
            in
            {
              options.icedos.configurationLocation = mkOption {
                type = types.str;
                default = "/home/stef/code/os/.state";
              };
            }
          )

          # Symlink configuration state on "/run/current-system/source"
          {
            # Source: https://github.com/NixOS/nixpkgs/blob/5e4fbfb6b3de1aa2872b76d49fafc942626e2add/nixos/modules/system/activation/top-level.nix#L191
            system.systemBuilderCommands = "ln -s ${self} $out/source";
          }

          # Remove nixos manual package
          {
            documentation.nixos.enable = false;
          }

          {
            imports = [
              "${inputs.icedos-core}/modules/nh.nix"
              "${inputs.icedos-core}/modules/nix.nix"
              "${inputs.icedos-core}/modules/rebuild.nix"
              "${inputs.icedos-core}/modules/state.nix"
              "${inputs.icedos-core}/modules/toolset.nix"
              "${inputs.icedos-core}/modules/users.nix"
            ];
          }

          # Internal modules and config
          {
            imports = [
              "${inputs.icedos-core}/modules/options.nix"
            ]
            ++ (
              if (pathExists "${inputs.icedos-config}/extra-modules") then
                (getModules "${inputs.icedos-config}/extra-modules")
              else
                [ ]
            );
            config.system.stateVersion = "23.05";
          }

          home-manager.nixosModules.home-manager

          { icedos.system.isFirstBuild = false; }

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
