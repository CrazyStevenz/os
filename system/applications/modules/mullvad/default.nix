{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf optional;

  cfg = config.icedos.applications;
in
mkIf (cfg.mullvad.enable) {
  environment.systemPackages = mkIf (cfg.mullvad.gui) [ pkgs.mullvad-vpn ];

  services.mullvad-vpn.enable = true;
}