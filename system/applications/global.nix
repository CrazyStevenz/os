{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) foldl' lists splitString;

  pkgMapper =
    pkgList: lists.map (pkgName: foldl' (acc: cur: acc.${cur}) pkgs (splitString "." pkgName)) pkgList;

  pkgFile = lib.importTOML ./packages.toml;
  myPackages = (pkgMapper pkgFile.myPackages);

  cfg = config.icedos;

  codingDeps = (pkgMapper pkgFile.codingDeps);

  # Logout from any shell
  lout = pkgs.writeShellScriptBin "lout" ''
    pkill -KILL -u $USER
  '';

  # Garbage collect the nix store
  nix-gc = import modules/nix-gc.nix { inherit config lib pkgs; };

  rebuild = import modules/rebuild.nix {
    inherit pkgs config;
    command = "rebuild";
    update = "false";
  };

  toggle-services = import modules/toggle-services.nix { inherit pkgs; };

  # Trim NixOS generations
  trim-generations = pkgs.writeShellScriptBin "trim-generations" (
    builtins.readFile ../../scripts/trim-generations.sh
  );

  packageWraps = with pkgs; [
    # Pipewire audio plugin for OBS Studio
    (pkgs.wrapOBS { plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ]; })
  ];

  shellScripts = [
    inputs.shell-in-netns.packages.${pkgs.system}.default
    lout
    nix-gc
    rebuild
    toggle-services
    trim-generations
  ];

  aagl-gtk-on-nix = import (
    builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz"
  );
in
{
  imports = [
    ./modules/android-tools.nix
    ./modules/aria2c.nix
    ./modules/bash.nix
    ./modules/brave.nix
    ./modules/btop
    ./modules/celluloid
    ./modules/clamav.nix
    ./modules/codium
    ./modules/container-manager.nix
    ./modules/gamemode.nix
    ./modules/gdm.nix
    ./modules/git.nix
    ./modules/kitty.nix
    ./modules/librewolf
    ./modules/libvirtd.nix
    ./modules/mangohud.nix
    ./modules/nvchad
    ./modules/steam.nix
    ./modules/sunshine.nix
    ./modules/tailscale.nix
    ./modules/tmux
    ./modules/waydroid.nix
    ./modules/zsh

    # Enable Genshin Impact launcher
    aagl-gtk-on-nix.module
  ];

  programs.anime-game-launcher.enable = true;
  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ];
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
  };

  boot.kernelPackages =
    # Use CachyOS optimized linux kernel
    if
      (
        !cfg.hardware.devices.steamdeck
        && !cfg.hardware.devices.server.enable
        && builtins.pathExists /etc/icedos-version
      )
    then
      pkgs.linuxPackages_cachyos
    else if (cfg.hardware.devices.server.enable && builtins.pathExists /etc/icedos-version) then
      pkgs.linuxPackages_cachyos-server
    else
      pkgs.linuxPackages_zen;

  environment.systemPackages =
    (pkgMapper pkgFile.packages) ++ myPackages ++ codingDeps ++ packageWraps ++ shellScripts;

  environment.variables = {
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.ungoogled-chromium}/bin/chromium";
  };

  programs = {
    direnv.enable = true;
  };

  services = {
    mullvad-vpn.enable = true;
    openssh.enable = true;
    fwupd.enable = true;
    udev.packages = with pkgs; [
      logitech-udev-rules # Needed for solaar to work
    ];
  };
}
