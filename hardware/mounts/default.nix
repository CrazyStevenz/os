{ lib, config, ... }:

let
  inherit (lib) mkIf optional;

  cfg = config.icedos.hardware;
in
{
  fileSystems = builtins.listToAttrs (
    map (mount: {
      name = mount.path;

      value = {
        device = mount.device;
        fsType = mount.fsType;
        options = mount.flags;
      };
    }) cfg.mounts
  );
}
