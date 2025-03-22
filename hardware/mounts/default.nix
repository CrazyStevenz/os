{ lib, config, ... }:

let
  inherit (lib) mkIf optional;

  cfg = config.icedos.hardware;
  btrfsCompression = cfg.btrfs.compression;
in
mkIf (cfg.mounts) {
  fileSystems."/mnt/Nvme" = {
    device = "/dev/disk/by-uuid/ebcec57e-2afb-49a7-8ae8-d6776a841f52";
    fsType = "btrfs";
    options = [
      "nofail" # Prevent system from failing if this drive doesn't mount
      "x-gvfs-show" # Make disk visible in file explorer
    ] ++ optional (btrfsCompression.enable && btrfsCompression.mounts) "compress=zstd";
  };

  fileSystems."/mnt/SSDGames" = {
    device = "/dev/disk/by-uuid/2b04380c-cefe-4915-a1f4-26bef6ebc360";
    fsType = "btrfs";
    options = [
      "nofail" # Prevent system from failing if this drive doesn't mount
      "x-gvfs-show" # Make disk visible in file explorer
    ] ++ optional (btrfsCompression.enable && btrfsCompression.mounts) "compress=zstd";
  };

  fileSystems."/mnt/HDDGames" = {
    device = "/dev/disk/by-uuid/e7e03cc8-e8fe-47e2-b48a-c6dbd1903112";
    fsType = "btrfs";
    options = [
      "nofail" # Prevent system from failing if this drive doesn't mount
      "x-gvfs-show" # Make disk visible in file explorer
    ] ++ optional (btrfsCompression.enable && btrfsCompression.mounts) "compress=zstd";
  };

  # fileSystems."/mnt/Windows" = {
  #   device = "/dev/disk/by-uuid/3032AC4732AC13BE";
  #   fsType = "ntfs";
  # };
}
