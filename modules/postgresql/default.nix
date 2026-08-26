{ pkgs, ... }:

{
  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_16;
    identMap = ''
      # ArbitraryMapName systemUser DBUser
        superuser_map    work       reader
    '';
  };
}
