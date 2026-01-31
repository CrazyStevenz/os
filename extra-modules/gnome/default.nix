{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mapAttrs mkIf;
  cfg = config.icedos;
in
{
  environment.systemPackages = [
    pkgs.gnomeExtensions.quick-settings-audio-devices-hider
    pkgs.gnomeExtensions.quick-settings-audio-devices-renamer
  ];

  home-manager.users = mapAttrs (user: _: {
    dconf.settings."org/gnome/shell" = {
      enabled-extensions = [
        "quicksettings-audio-devices-hider@marcinjahn.com"
        "quicksettings-audio-devices-renamer@marcinjahn.com"
      ];
    };
  }) cfg.users;
}
