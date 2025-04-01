{
  lib,
  ...
}:

let
  inherit (lib) fileContents mkOption types;
  mkBoolOption = mkOption { type = types.bool; };
  mkLinesOption = mkOption { type = types.lines; };
  mkNumberOption = mkOption { type = types.number; };
  mkStrListOption = mkOption { type = with types; listOf str; };
  mkStrOption = mkOption { type = types.str; };

  mkSubmoduleAttrsOption =
    options:
    mkOption {
      type = types.attrsOf (
        types.submodule {
          options = options;
        }
      );
    };

  mkSubmoduleListOption =
    options:
    mkOption {
      type = types.listOf (
        types.submodule {
          options = options;
        }
      );
    };
in
{
  options = {
    icedos = {
      applications = {
        aagl = mkBoolOption;
        android-tools = mkBoolOption;
        celluloid = mkBoolOption;
        clamav = mkBoolOption;

        codium = {
          enable = mkBoolOption;
          zoomLevel = mkNumberOption;
        };

        defaultBrowser = mkStrOption;
        defaultEditor = mkStrOption;
        extraPackages = mkStrListOption;
        input-remapper = mkBoolOption;

        kitty = {
          enable = mkBoolOption;
          hideDecorations = mkBoolOption;
        };

        librewolf = mkBoolOption;

        mangohud = {
          enable = mkBoolOption;
          maxFpsLimit = mkNumberOption;
        };

        nautilus = mkBoolOption;

        network-manager = {
          enable = mkBoolOption;
          applet = mkBoolOption;
        };

        obs-studio = {
          enable = mkBoolOption;
          virtualCamera = mkBoolOption;
        };

        php = mkBoolOption;
        rust = mkBoolOption;

        signal = {
          enable = mkBoolOption;
          package = mkStrOption;
        };

        solaar = mkBoolOption;
        ssh = mkBoolOption;

        steam = {
          enable = mkBoolOption;
          beta = mkBoolOption;
          downloadsWorkaround = mkBoolOption;

          session = {
            enable = mkBoolOption;

            autoStart = {
              enable = mkBoolOption;
              desktopSession = mkStrOption;
            };

            user = mkStrOption;
          };
        };

        sunshine = mkBoolOption;

        tailscale = {
          enable = mkBoolOption;
          enableTrayscale = mkBoolOption;
        };

        valent = {
          enable = mkBoolOption;
          deviceId = mkStrOption;
        };

        zed = {
          enable = mkBoolOption;
          ollamaSupport = mkBoolOption;
          vim = mkBoolOption;

          theme = {
            dark = mkStrOption;
            light = mkStrOption;
            mode = mkStrOption;
          };
        };

        zen-browser = {
          enable = mkBoolOption;
          privacy = mkBoolOption;

          profiles = mkSubmoduleListOption {
            default = mkBoolOption;
            exec = mkStrOption;
            icon = mkStrOption;
            name = mkStrOption;
            pwa = mkBoolOption;
            sites = mkStrListOption;
          };
        };
      };

      bootloader = {
        animation = mkBoolOption;

        grub = {
          enable = mkBoolOption;
          device = mkStrOption;
        };

        systemd-boot = {
          enable = mkBoolOption;
          mountPoint = mkStrOption;
        };
      };

      desktop = {
        accentColor = mkStrOption;

        autologin = {
          enable = mkBoolOption;
          user = mkStrOption;
        };

        gdm = {
          enable = mkBoolOption;
          autoSuspend = mkBoolOption;
        };

        gnome = {
          enable = mkBoolOption;
          accentColor = mkStrOption;

          extensions = {
            arcmenu = mkBoolOption;
            dashToPanel = mkBoolOption;
          };

          clock = {
            date = mkBoolOption;
            weekday = mkBoolOption;
          };

          hotCorners = mkBoolOption;
          powerButtonAction = mkStrOption;
          titlebarLayout = mkStrOption;

          workspaces = {
            dynamicWorkspaces = mkBoolOption;
            maxWorkspaces = mkNumberOption;
          };
        };

        hyprland = {
          enable = mkBoolOption;

          cs2fix = {
            enable = mkBoolOption;
            width = mkNumberOption;
            height = mkNumberOption;
          };

          followMouse = mkNumberOption;
          hyprspace = mkBoolOption;

          hyproled = {
            enable = mkBoolOption;
            startWidth = mkNumberOption;
            startHeight = mkNumberOption;
            endWidth = mkNumberOption;
            endHeight = mkNumberOption;
          };

          lock = {
            secondsToLowerBrightness = mkNumberOption;
            cpuUsageThreshold = mkNumberOption;
            diskUsageThreshold = mkNumberOption;
            networkUsageThreshold = mkNumberOption;
          };

          startupScript = mkStrOption;
          windowRules = mkStrListOption;
        };
      };

      hardware = {
        bluetooth = mkBoolOption;

        cpus = {
          amd = {
            enable = mkBoolOption;

            undervolt = {
              enable = mkBoolOption;
              value = mkStrOption;
            };

            zenpower = mkBoolOption;
          };

          intel = mkBoolOption;
        };

        devices = {
          laptop = mkBoolOption;

          server = {
            enable = mkBoolOption;
            dns = mkStrOption;
            gateway = mkStrOption;
            interface = mkStrOption;
            ip = mkStrOption;
          };

          steamdeck = mkBoolOption;
        };

        drivers.rtl8821ce = mkBoolOption;

        gpus = {
          amd = {
            enable = mkBoolOption;
            rocm = mkBoolOption;
          };

          nvidia = {
            enable = mkBoolOption;
            beta = mkBoolOption;
            cuda = mkBoolOption;
            openDrivers = mkBoolOption;

            powerLimit = {
              enable = mkBoolOption;
              value = mkNumberOption;
            };
          };
        };

        monitors = mkSubmoduleListOption {
          name = mkStrOption;
          disable = mkBoolOption;
          resolution = mkStrOption;
          refreshRate = mkNumberOption;
          position = mkStrOption;
          scaling = mkNumberOption;
          rotation = mkNumberOption;
          tenBit = mkBoolOption;
        };

        networking = {
          hostname = mkStrOption;
          hosts = mkLinesOption;
          ipv6 = mkBoolOption;
          vpnExcludeIp = mkStrOption;

          wg-quick = {
            enable = mkBoolOption;
            interfaces = mkStrListOption;
          };
        };

        mounts = mkSubmoduleListOption {
          path = mkStrOption;
          device = mkStrOption;
          fsType = mkStrOption;
          flags = mkStrListOption;
        };
      };

      system = {
        channels = mkStrListOption;
        forceFirstBuild = mkBoolOption;

        generations = {
          bootEntries = mkNumberOption;

          garbageCollect = {
            automatic = mkBoolOption;
            days = mkNumberOption;
            generations = mkNumberOption;
            interval = mkStrOption;
          };
        };

        home = mkStrOption;
        kernel = mkStrOption;
        swappiness = mkNumberOption;

        users = mkSubmoduleAttrsOption {
          description = mkStrOption;
          type = mkStrOption;

          applications = {
            codium = {
              autoSave = mkStrOption;
              formatOnSave = mkBoolOption;
              formatOnPaste = mkBoolOption;
            };

            git = {
              username = mkStrOption;
              email = mkStrOption;
            };
          };

          desktop = {
            gnome = {
              pinnedApps = {
                arcmenu = {
                  enable = mkBoolOption;
                  list = mkStrListOption;
                };

                shell = {
                  enable = mkBoolOption;
                  list = mkStrListOption;
                };
              };

              startupScript = mkStrOption;
            };

            idle = {
              lock = {
                enable = mkBoolOption;
                seconds = mkNumberOption;
              };

              disableMonitors = {
                enable = mkBoolOption;
                seconds = mkNumberOption;
              };

              suspend = {
                enable = mkBoolOption;
                seconds = mkNumberOption;
              };
            };
          };
        };

        virtualisation = {
          containerManager = {
            enable = mkBoolOption;
            usePodman = mkBoolOption;
            requireSudoForDocker = mkBoolOption;
          };

          virtManager = mkBoolOption;
          waydroid = mkBoolOption;
        };

        version = mkStrOption;
      };
    };
  };

  config = fromTOML (fileContents ./config.toml);
}
