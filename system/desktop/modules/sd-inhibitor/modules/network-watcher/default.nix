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
  home-manager.users = mapAttrs (user: _: {
    home.packages =
      let
        watcher = cfg.system.users.${user}.desktop.idle.sd-inhibitor.watchers.network;
      in
      mkIf (cfg.system.users.${user}.desktop.idle.sd-inhibitor.enable && watcher.enable) [
        (pkgs.writeShellScriptBin "network-watcher" ''
          NETWORK_THRESHOLD=${toString (watcher.threshold)}
          INTERFACE=$(ip route | head -n 1 | grep -oP 'dev \K\S+')
          NETWORK_USAGE=($(awk '{if(l1){print ($2-l1),($10-l2)} else{l1=$2; l2=$10;}}' \
              <(grep "$INTERFACE" /proc/net/dev) <(sleep 1; grep "$INTERFACE" /proc/net/dev)))

          if (( NETWORK_USAGE[0] > NETWORK_THRESHOLD )) || (( NETWORK_USAGE[1] > NETWORK_THRESHOLD )); then
            printf true
          else
            printf false
          fi
        '')
      ];
  }) cfg.system.users;
}
