{ lib, config, ... }:

lib.mkIf config.hardware.mounts.enable {
  fileSystems."/mnt/Nvme" = {
    device = "/dev/disk/by-uuid/ebcec57e-2afb-49a7-8ae8-d6776a841f52";
    fsType = "btrfs";
    options = lib.mkIf (config.hardware.btrfs-compression.enable
      && config.hardware.btrfs-compression.mounts.enable) [
        "compress=zstd"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/SSDGames" = {
    device = "/dev/disk/by-uuid/2b04380c-cefe-4915-a1f4-26bef6ebc360";
    fsType = "btrfs";
    options = lib.mkIf (config.hardware.btrfs-compression.enable
      && config.hardware.btrfs-compression.mounts.enable) [
        "compress=zstd"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/HDDGames" = {
    device = "/dev/disk/by-uuid/e7e03cc8-e8fe-47e2-b48a-c6dbd1903112";
    fsType = "btrfs";
    options = lib.mkIf (config.hardware.btrfs-compression.enable
      && config.hardware.btrfs-compression.mounts.enable) [
        "compress=zstd"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/Windows" = {
    device = "/dev/disk/by-uuid/3032AC4732AC13BE";
    fsType = "ntfs";
  };
}
