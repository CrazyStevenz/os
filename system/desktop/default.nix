{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) attrNames filterAttrs mkIf;
  cfg = config.icedos;

  getModules =
    path:
    map (dir: ./. + ("/modules/" + dir)) (
      attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir path))
    );

  # Use monitor configuration for GDM (desktop monitor primary). See https://discourse.nixos.org/t/gdm-monitor-configuration/6356/4
  monitorsConfig =
    pkgs.runCommand "gdm_monitors.xml" { }
      "ln -s /home/stef/.config/monitors.xml $out";
in
{
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  ];

  imports = getModules (./modules);
  time.timeZone = "Europe/Bucharest";

  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings.LC_MEASUREMENT = "es_ES.utf8";
  };

  services = {
    displayManager.autoLogin =
      mkIf (cfg.desktop.autologin.enable && !cfg.applications.steam.session.autoStart.enable)
        {
          enable = true;
          user = cfg.desktop.autologin.user;
        };
  };

  environment = {
    systemPackages = with pkgs; [
      adwaita-icon-theme # Gtk theme
      amberol # Music player
      dconf-editor # Edit gnome's dconf
      libnotify # Send desktop notifications
      libreoffice-fresh # Office tools
      loupe # Image viewer
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    meslo-lgs-nf
    nerd-fonts.jetbrains-mono
  ];

  xdg.portal.config.common.default = "*";
}
