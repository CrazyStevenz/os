{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) optional;
  cfg = config.icedos;

  emulators = [
    # cemu # Wiuu
    # duckstation # PS1
    # heroic
    # pcsx2 # PS2
    # ppsspp # PSP
    # prismlauncher
    # rpcs3 # PS3
  ];
in
{
  users.users.stef.packages =
    with pkgs;
    [
      appimage-run # Appimage runner
      bottles # Wine manager
      flac # Library and tools for encoding and decoding the FLAC lossless audio file format
      fragments # BitTorrent client
      # ghex # HEX Editor
      gimp # Image editor
      # heroic # Cross-platform Epic Games Launcher
      newsflash # RSS reader
      nicotine-plus # p2p music sharing platform
      # obs-studio, # Recording/Livestream
      # prismlauncher # Minecraft launcher
      # protontricks # Winetricks for proton prefixes
      # protonup-qt
      spek # Audio file spectrogram analysis
      stremio # Media streaming platform
      warp # File sync
      # wine # Compatibility layer capable of running Windows applications
      # winetricks # Wine prefix settings manager
    ]
    ++ emulators
    ++ optional (cfg.applications.falkor) inputs.falkor.packages.${pkgs.system}.default
    ++ optional (cfg.applications.suyu) inputs.switch-emulators.packages.${pkgs.system}.suyu;
}
