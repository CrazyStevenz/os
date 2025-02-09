{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.icedos.hardware;
  btrfsCompression = cfg.btrfs.compression;
in
mkIf (cfg.mounts) {
  fileSystems."/mnt/C" = {
    device = "/dev/disk/by-uuid/6C383F39383F021E";
    fsType = "ntfs";
  };

  fileSystems."/mnt/D" = {
    device = "/dev/disk/by-uuid/5cf83e52-be67-1c2a-a5f8-72c38068e1f0";
    fsType = "btrfs";
    options = mkIf (btrfsCompression.enable && btrfsCompression.mounts) [
      "compress=zstd"
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems."/mnt/HDD" = {
    device = "/dev/disk/by-uuid/42B629A5B6299B05";
    fsType = "ntfs";
  };
}
