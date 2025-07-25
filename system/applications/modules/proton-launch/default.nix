{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    head
    last
    mapAttrs
    mkIf
    optional
    splitString
    ;

  cfg = config.icedos;
  packages = [ proton-launch ] ++ optional (cfg.applications.gamescope) pkgs.gamescope;

  proton-launch = (
    pkgs.writeShellScriptBin "proton-launch" ''
      GAMEMODE="${pkgs.gamemode}/bin/gamemoderun"
      SDL="--backend sdl"
      PROTON_ENABLE_WAYLAND=1
      PROTON_USE_NTSYNC=1
      PROTON_USE_WOW64=1

      ${
        if (cfg.applications.mangohud.enable) then
          ''
            MANGOAPP="--mangoapp"
            MANGOHUD="${pkgs.mangohud}/bin/mangohud"
            MANGOHUD_CONFIGFILE="/home/$USER/.config/MangoHud/MangoHud.conf"
          ''
        else
          ""
      }

      ${
        if (cfg.applications.lsfg-vk.enable) then
          ''
            ENABLE_LSFG=1
            LSFG_PERF_MODE=1
          ''
        else
          ""
      }

      ${
        let
          monitor = head (cfg.hardware.monitors);
          resolution = splitString "x" (monitor.resolution);
          width = head (resolution);
          height = last (resolution);
          refreshRate = toString (monitor.refreshRate);
        in
        ''
          DEFAULT_WIDTH="-W ${width}"
          DEFAULT_HEIGHT="-H ${height}"
          DEFAULT_REFRESH_RATE="-r ${refreshRate}"
        ''
      }

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --fsr4)
            PROTON_FSR4_UPGRADE=1
            shift
            ;;
          --hdr)
            PROTON_ENABLE_HDR=1
            shift
            ;;
          --gamescope)
            ${
              if (cfg.applications.gamescope) then
                ''
                  GAMESCOPE="${pkgs.scopebuddy}/bin/scopebuddy --"
                ''
              else
                ""
            }
            shift
            ;;
          --gamescope-args)
            GAMESCOPE_ARGS="$2"

            if [[ $GAMESCOPE_ARGS = *'-W'* ]] || [[ $GAMESCOPE_ARGS = *'-H'* ]]; then
              DEFAULT_WIDTH=""
              DEFAULT_HEIGHT=""
            fi

            if [[ $GAMESCOPE_ARGS = *'-r'* ]]; then
              DEFAULT_REFRESH_RATE=""
            fi

            shift 2
            ;;
          --no-gamemode)
            GAMEMODE=""
            shift
            ;;
          --no-lsfg)
            ENABLE_LSFG=0
            shift
            ;;
          --no-mangohud)
            MANGOHUD=""
            MANGOAPP=""
            shift
            ;;
          --no-sdl)
            SDL=""
            shift
            ;;
          --no-wayland)
            PROTON_ENABLE_WAYLAND=0
            shift
            ;;
          --no-ntsync)
            PROTON_USE_NTSYNC=0
            shift
            ;;
          --no-wow64)
            PROTON_USE_WOW64=0
            shift
            ;;
          --)
            shift
            COMMAND=("$@")
            break
            ;;
          *)
            COMMAND=("$@")
            break
            ;;
          -*|--*)
            echo "Unknown arg: $1" >&2
            exit 1
            ;;
        esac
      done

      SCB_GAMESCOPE_ARGS="$DEFAULT_HEIGHT $DEFAULT_REFRESH_RATE $DEFAULT_WIDTH $GAMESCOPE_ARGS $MANGOAPP $SDL"

      export ENABLE_LSFG LSFG_PERF_MODE PROTON_ENABLE_HDR PROTON_ENABLE_WAYLAND PROTON_FSR4_UPGRADE PROTON_USE_NTSYNC PROTON_USE_WOW64 SCB_GAMESCOPE_ARGS

      [[ "$MANGOAPP" != "" && "$GAMESCOPE" != "" ]] && MANGOHUD=""

      $MANGOHUD $GAMEMODE $GAMESCOPE "''${COMMAND[@]}"
    ''
  );

  ifSteam = deck: cfg.applications.steam.enable && deck;
in
mkIf (cfg.applications.proton-launch) {
  environment.systemPackages = packages;

  icedos.internals.toolset.commands = [
    (
      let
        command = "proton-launch";
      in
      {
        bin = "${proton-launch}/bin/${command}";
        command = command;
        help = "launch exec using optimal usage flags for gaming";
      }
    )
  ];

  programs.steam.extraPackages = mkIf (ifSteam (cfg.hardware.devices.steamdeck)) packages;

  home-manager.users = mapAttrs (user: _: {
    home.packages = mkIf (ifSteam (!cfg.hardware.devices.steamdeck)) [
      (pkgs.steam.override { extraPkgs = pkgs: packages; })
    ];
  }) cfg.system.users;
}
