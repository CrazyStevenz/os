{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrNames
    filter
    foldl'
    makeSearchPathOutput
    mkIf
    ;

  cfg = config.icedos;

  mapAttrsAndKeys = callback: list: (foldl' (acc: value: acc // (callback value)) { } list);
in
{
  environment = {
    systemPackages = [ pkgs.nautilus ];

    sessionVariables = {
      # Fix for missing audio/video information in properties https://github.com/NixOS/nixpkgs/issues/53631
      GST_PLUGIN_SYSTEM_PATH_1_0 = makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
        with pkgs.gst_all_1;
        [
          gst-plugins-good
          gst-plugins-bad
          gst-plugins-ugly
          gst-libav
        ]
      ); # Fix from https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1366902737
    };
  };

  services.gvfs.enable = true;

  home-manager.users =
    let
      users = filter (user: cfg.system.users.${user}.enable == true) (attrNames cfg.system.users);
    in
    mapAttrsAndKeys (
      user:
      let
        username = cfg.system.users.${user}.username;
      in
      {
        ${username} = {
          dconf.settings = {
            "org/gnome/nautilus/preferences" = {
              always-use-location-entry = true;
            };

            "org/gtk/gtk4/settings/file-chooser" = {
              sort-directories-first = true;
              show-hidden = true;
            };
          };

          home.file = {
            "Templates/new".text = "";
            "Templates/new.cfg".text = "";
            "Templates/new.ini".text = "";
            "Templates/new.sh".text = "";
            "Templates/new.txt".text = "";
          };
        };
      }
    ) users;
}
