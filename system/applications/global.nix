{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.icedos;

  # Logout from any shell
  lout = pkgs.writeShellScriptBin "lout" ''
    pkill -KILL -u $USER
  '';

  # Garbage collect the nix store
  nix-gc = pkgs.writeShellScriptBin "nix-gc" ''
    gens=${cfg.system.gc.generations} ;
    days=${cfg.system.gc.days} ;
    trim-generations ''${1:-$gens} ''${2:-$days} user ;
    trim-generations ''${1:-$gens} ''${2:-$days} home-manager ;
    sudo -H -u ${cfg.system.user.work.username} env Gens="''${1:-$gens}" Days="''${2:-$days}" bash -c 'trim-generations $Gens $Days user' ;
    sudo -H -u ${cfg.system.user.work.username} env Gens="''${1:-$gens}" Days="''${2:-$days}" bash -c 'trim-generations $Gens $Days home-manager' ;
    sudo trim-generations ''${1:-$gens} ''${2:-$days} system ;
    nix-store --gc
  '';

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

  update-codium-extensions = import modules/codium-extension-updater.nix { inherit pkgs; };

  codingDeps = with pkgs; [
    # bruno # API explorer
    cargo # Rust package manager
    # dotnet-sdk_7 # SDK for .net
    # gcc # C++ compiler
    # gdtoolkit # Tools for gdscript
    # gnumake # A tool to control the generation of non-source files from sources
    nixfmt-rfc-style # A nix formatter
    nodejs_18 # Node package manager
    python3 # Python
    vscodium # All purpose IDE
  ];

  # Packages to add for a fork of the config
  myPackages = with pkgs; [
    adw-gtk3 # Adds libadwaita support to GTK-3
    amberol # A small and simple sound and music player
    audacity # Sound editor with graphical UI
    bun # Incredibly fast JavaScript runtime, bundler, transpiler and package manager
    gradience # Customize libadwaita and GTK3 apps (with adw-gtk3)
    gsound # Small library for playing system sounds (required to show file properties in Nautilus)
    mullvad-vpn # The GUI client for mullvad
    nextcloud-client # Nextcloud themed desktop client
    pavucontrol # Sound manager
    spotify # Music streaming service
    stremio # Movie/Series/Anime streaming service
    ungoogled-chromium # Chromium with dependencies on Google web services removed
    webcord # An open source discord client
  ];

  nvchadDeps = with pkgs; [
    # beautysh # Bash formatter
    # black # Python formatter
    # lazygit # Git CLI UI
    # libclang # C language server and formatter
    # lua-language-server # Lua language server
    # marksman # Markdown language server
    # neovim # Terminal text editor
    # nil # Nix language server
    # nodePackages.bash-language-server # Bash Language server
    # nodePackages.dockerfile-language-server-nodejs # Dockerfiles language server
    # nodePackages.eslint # An AST-based pattern checker for JavaScript
    # nodePackages.intelephense # PHP language server
    # nodePackages.prettier # Javascript/Typescript formatter
    # nodePackages.typescript-language-server # Typescript language server
    # nodePackages.vscode-langservers-extracted # HTML, CSS, Eslint, Json language servers
    # phpPackages.phpstan # PHP Static Analysis Tool
    # python3Packages.jedi-language-server # Python language server
    # ripgrep # Silver searcher grep
    # rust-analyzer # Rust language server
    # rustfmt # Rust formatter
    # shellcheck # Shell script analysis tool
    # stylua # Lua formatter
    # tailwindcss-language-server # Tailwind language server
    # tree-sitter # Parser generator tool and an incremental parsing library
  ];

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
    update-codium-extensions
  ];
in
{
  imports = [ configs/pipewire.nix ];

  boot.kernelPackages = mkIf (
    !cfg.hardware.steamdeck && builtins.pathExists /etc/icedos-version
  ) pkgs.linuxPackages_cachyos; # Use CachyOS optimized linux kernel

  environment.systemPackages =
    with pkgs;
    [
      # appimage-run # Appimage runner
      # aria # Terminal downloader with multiple connections support
      # bat # Better cat command
      # bless # HEX Editor
      btop # System monitor
      celluloid # Video player
      clamav # Antivirus
      curtail # Image compressor
      # easyeffects # Pipewire effects manager
      efibootmgr # Edit EFI entries
      # endeavour # Tasks
      fd # Find alternative
      # flowblade # Video editor
      fragments # Bittorrent client following Gnome UI standards
      gimp # Image editor
      gping # ping with a graph
      # gthumb # Image viewer
      helvum # Pipewire patchbay
      # iotas # Notes
      # jc # JSON parser
      jq # JSON parser
      killall # Tool to kill all programs matching process name
      kitty # Terminal
      # logseq # Note taking with nodes
      lsd # Better ls command
      mission-center # Task manager
      # moonlight-qt # Remote streaming
      mousai # Song recognizer
      ncdu # Terminal disk analyzer
      newsflash # RSS reader
      nix-health # Check system health
      ntfs3g # Support NTFS drives
      obs-studio # Recording/Livestream
      onlyoffice-bin # Microsoft Office alternative for Linux
      p7zip # 7zip
      pavucontrol # Sound manager
      # ranger # Terminal file manager
      rnnoise-plugin # A real-time noise suppression plugin
      scrcpy # Remotely use android
      signal-desktop # Encrypted messaging platform
      # solaar # Logitech devices manager
      # sunshine # Remote desktop
      tailscale # VPN with P2P support
      tmux # Terminal multiplexer
      trayscale # Tailscale GUI
      tree # Display folder content at a tree format
      unrar # Support opening rar files
      unzip # An extraction utility
      warp # File sync
      wget # Terminal downloader
      wine # Compatibility layer capable of running Windows applications
      winetricks # Wine prefix settings manager
      # woeusb # Windows ISO Burner
      xorg.xhost # Use x.org server with docker
      # youtube-dl # Video downloader
      zenstates # Ryzen CPU controller
    ]
    ++ codingDeps
    ++ nvchadDeps
    ++ myPackages
    ++ packageWraps
    ++ shellScripts;

  environment.variables = {
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.ungoogled-chromium}/bin/chromium";
  };

  users.defaultUserShell = pkgs.zsh; # Use ZSH shell for all users

  programs = {
    adb.enable = true;
    direnv.enable = true;

    zsh = {
      enable = true;
      # Enable oh my zsh and it's plugins
      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "npm"
          "sudo"
          "systemd"
        ];
      };
      autosuggestions.enable = true;

      syntaxHighlighting.enable = true;

      # Aliases
      shellAliases = {
        a2c = "aria2c -j 16 -s 16"; # Download with aria using best settings
        bcompress = "sudo btrfs filesystem defrag -czstd -r -v"; # Compress given path with zstd
        # cat = "bat"; # Better cat command
        cp = "rsync -rP"; # Copy command with details
        l-pkgs = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq"; # List installed nix packages
        ls = "lsd"; # Better ls command
        mv = "rsync -rP --remove-source-files"; # Move command with details
        n = "tmux a -t nvchad || tmux new -s nvchad nvim"; # Nvchad
        ping = "gping"; # ping with a graph
        r-pipewire = "systemctl --user restart pipewire"; # Restart pipewire
        # r-store = "nix-store --verify --check-contents --repair"; # Verifies integrity and repairs inconsistencies between Nix database and store
        # r-windows = "sudo efibootmgr --bootnext ${cfg.boot.windowsEntry} && reboot"; # Reboot to windows
        ssh = "TERM=xterm-256color ssh"; # SSH with colors
        v = "nvim"; # Neovim
      };

      # Commands to run on zsh shell initialization
      interactiveShellInit = ''
        source ~/.config/zsh/zsh-theme.zsh
        export EDITOR=nvim
        unsetopt PROMPT_SP'';
    };

    # Enable gamemode and set custom settings
    gamemode = {
      enable = true;
      settings = {
        general.renice = 20;
        gpu = {
          apply_gpu_optimisations = 1;
          nv_powermizer_mode = 1;
          amd_performance_level = "high";
        };
      };
    };
  };

  security.wrappers = {
    sunshine = {
      owner = "root";
      group = "root";
      source = "${pkgs.sunshine}/bin/sunshine";
      capabilities = "cap_sys_admin+p";
    };
  };

  services = {
    clamav.updater.enable = true;
    mullvad-vpn.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    fwupd.enable = true;
    udev.packages = with pkgs; [
      (writeTextFile {
        name = "sunshine_udev";
        text = ''
          KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/85-sunshine.rules";
      }) # Needed for sunshine input to work
      logitech-udev-rules # Needed for solaar to work
    ];
  };
}
