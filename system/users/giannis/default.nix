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
    # cemu
    # duckstation
    # heroic
    # pcsx2
    # ppsspp
    # prismlauncher
    # rpcs3
  ];
in
{
  users.users.giannis.packages =
    with pkgs;
    [
      appimage-run
      bottles
      warp
    ]
    ++ emulators
    ++ optional (cfg.applications.falkor) inputs.falkor.packages.${pkgs.system}.default
    ++ optional (cfg.applications.suyu) inputs.switch-emulators.packages.${pkgs.system}.suyu;
}
