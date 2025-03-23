{
  pkgs,
  ...
}:

let
  launchers = with pkgs; [
    # cemu # Wiuu
    # duckstation # PS1
    # heroic # Cross-platform Epic Games Launcher
    # pcsx2 # PS2
    # ppsspp # PSP
    # prismlauncher # Minecraft launcher
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
      newsflash # RSS reader
      nicotine-plus # p2p music sharing platform
      # protontricks # Winetricks for proton prefixes
      # protonup-qt # Install and manage Proton-GE and Luxtorpeda for Steam and Wine-GE
      spek # Audio file spectrogram analysis
      stremio # Media streaming platform
      # wine # Compatibility layer capable of running Windows applications
      # winetricks # Wine prefix settings manager
    ]
    ++ launchers;
}
