{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) filterAttrs mkIf;
  cfg = config.icedos;

  getModules =
    path:
    builtins.map (dir: ./. + ("/modules/" + dir)) (
      builtins.attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir path))
    );

in
# Use monitor configuration for GDM (desktop monitor primary). See https://discourse.nixos.org/t/gdm-monitor-configuration/6356/4
# monitorsConfig =
#   pkgs.runCommand "gdm_monitors.xml" { }
#     "ln -s /home/stef/.config/monitors.xml $out";
{
  # systemd.tmpfiles.rules = [
  #   "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  # ];

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

  networking = {
    networkmanager.enable = !cfg.hardware.devices.server.enable;
    firewall.enable = false;
  };

  environment = {
    # Packages to install for all window manager/desktop environments
    systemPackages = with pkgs; [
      adwaita-icon-theme # Gtk theme
      amberol # Music player
      dconf-editor # Edit gnome's dconf
      libnotify # Send desktop notifications
      loupe # Image viewer
      onlyoffice-bin # Office tools
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
