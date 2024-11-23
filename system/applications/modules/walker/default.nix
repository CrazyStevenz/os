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
mkIf (cfg.applications.walker) {
  environment.systemPackages = with pkgs; [
    walker
    wl-clipboard
  ];

  home-manager.users = mapAttrs (user: _: {
    home.file = {
      ".config/walker/themes/theme.css".source = ./theme.css;
      ".config/walker/themes/theme.json".source = ./theme.json;
    };

    systemd.user.services.walker = {
      Unit.Description = "Walker - Application Runner";
      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
        Nice = "-20";
        Restart = "on-failure";
      };
    };
  }) cfg.system.users;
}
