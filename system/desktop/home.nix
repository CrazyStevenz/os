{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mapAttrs;
  cfg = config.icedos;

  browser =
    if (cfg.applications.librewolf.enable && cfg.applications.librewolf.default) then
      "librewolf.desktop"
    else if (cfg.applications.zen-browser.enable && cfg.applications.zen-browser.default) then
      "zen.desktop"
    else
      "";

  accentColor =
    if (!cfg.desktop.gnome.enable) then
      cfg.desktop.accentColor
    else
      {
        blue = "#3584e4";
        green = "#3a944a";
        orange = "#ed5b00";
        pink = "#d56199";
        purple = "#9141ac";
        red = "#e62d42";
        slate = "#6f8396";
        teal = "#2190a4";
        yellow = "#c88800";
      }
      .${cfg.desktop.gnome.accentColor};

  gtkCss = ''
    @define-color accent_bg_color ${accentColor};
    @define-color accent_color @accent_bg_color;
  '';
in
{
  home-manager.users = mapAttrs (user: _: {
    gtk = {
      enable = true;

      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      cursorTheme.name = "Bibata-Modern-Classic";
      iconTheme.name = "Tela-black-dark";

      gtk3.extraCss = gtkCss;
    };

    dconf.settings = {
      # Enable dark mode
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";

      # GTK file picker
      "org/gtk/settings/file-chooser" = {
        sort-directories-first = true;
        date-format = "with-time";
        show-type-column = false;
        show-hidden = true;
      };
    };

    xdg = {
      configFile = {
        "gtk-4.0/gtk.css".enable = false;
        "mimeapps.list".force = true;
      };

      # Default apps
      mimeApps = {
        enable = true;

        defaultApplications = {
          "application/pdf" = browser;
          "application/x-bittorrent" = "de.haeckerfelix.Fragments.desktop";
          "application/x-ms-dos-executable" = "wine.desktop";
          "application/x-shellscript" = "codium.desktop";
          "application/x-wine-extension-ini" = "codium.desktop";
          "application/x-zerosize" = "codium.desktop";
          "application/xhtml_xml" = browser;
          "application/xhtml+xml" = browser;
          "application/zip" = "org.gnome.FileRoller.desktop";
          "audio/aac" = "io.bassi.Amberol.desktop";
          "audio/flac" = "io.bassi.Amberol.desktop";
          "audio/mp3" = "io.bassi.Amberol.desktop";
          "audio/wav" = "io.bassi.Amberol.desktop";
          "image/avif" = "org.gnome.Loupe.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          "image/svg+xml" = "org.gnome.Loupe.desktop";
          "text/html" = browser;
          "text/plain" = "codium.desktop";
          "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
          "video/quicktime" = "io.github.celluloid_player.Celluloid.desktop";
          "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
          "video/x-ms-wmv" = "io.github.celluloid_player.Celluloid.desktop";
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/unknown" = browser;
          "x-www-browser" = browser;
        };
      };
    };

    home.file = {
      ".icons/default" = {
        source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic";
        recursive = true;
      };

      ".config/gtk-4.0/gtk.css".text = gtkCss;
    };
  }) cfg.system.users;
}
