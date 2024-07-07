{ config, ... }:

let
  cfg = config.icedos.system.config;
in
{
  imports = [
    ./configs/pipewire.nix
    ./global.nix
    ./home.nix
    ./modules/android-tools.nix
    ./modules/brave.nix
    ./modules/codium
    ./modules/firefox
    ./modules/librewolf
    ./modules/nvchad
    ./modules/sunshine.nix
  ];

  nix = {
    settings = {
      # Use hard links to save space (slows down package manager)
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ]; # Enable flakes
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  nixpkgs.config = {
    # Allow proprietary packages
    allowUnfree = true;
  };

  # Versioning system
  environment.etc."icedos-version".text = cfg.version;
}
