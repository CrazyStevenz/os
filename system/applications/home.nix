{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    attrNames
    filter
    foldl'
    mkIf
    ;

  cfg = config.icedos;

  mapAttrsAndKeys = callback: list: (foldl' (acc: value: acc // (callback value)) { } list);
in
{
  home-manager.users =
    let
      users = filter (user: cfg.system.users.${user}.enable == true) (attrNames cfg.system.users);
    in
    mapAttrsAndKeys (
      user:
      let
        username = cfg.system.users.${user}.username;
      in
      {
        ${username} = {
          programs = {
            git = {
              enable = true;
              # Git config
              extraConfig = {
                pull.rebase = true;
              };
              userName = "${cfg.system.users.${user}.applications.git.username}";
              userEmail = "${cfg.system.users.${user}.applications.git.email}";
            };

            kitty = {
              enable = (user != "server");
              settings = {
                background_opacity = "0.8";
                confirm_os_window_close = "0";
                cursor_shape = "beam";
                enable_audio_bell = "no";
                hide_window_decorations = if (cfg.applications.kitty.hideDecorations) then "yes" else "no";
                update_check_interval = "0";
                copy_on_select = "no";
                wayland_titlebar_color = "background";
              };
              font.name = "JetBrainsMono Nerd Font";
              font.size = 10;
              theme = "Catppuccin-Mocha";
            };

            mangohud = {
              enable = (user != "server" && user != "work");

              settings = {
                background_alpha = 0;
                battery = (cfg.hardware.devices.laptop || cfg.hardware.devices.steamdeck);
                battery_icon = (cfg.hardware.devices.laptop || cfg.hardware.devices.steamdeck);
                battery_time = (cfg.hardware.devices.laptop || cfg.hardware.devices.steamdeck);
                cpu_color = "FFFFFF";
                cpu_power = true;
                cpu_temp = true;
                engine_color = "FFFFFF";
                engine_short_names = true;
                font_size = 18;
                fps_color = "FFFFFF";
                fps_limit = "${builtins.toString (cfg.hardware.monitors.a.refreshRate)},60,0";
                frame_timing = false;
                frametime = false;
                gl_vsync = 0;
                gpu_color = "FFFFFF";
                gpu_power = true;
                gpu_temp = true;
                horizontal = true;
                hud_compact = true;
                hud_no_margin = true;
                no_small_font = true;
                offset_x = 5;
                offset_y = 5;
                text_color = "FFFFFF";
                toggle_fps_limit = "Ctrl_L+Shift_L+F1";
                vram_color = "FFFFFF";
                vsync = 1;
              };
            };

            zsh = {
              enable = true;

              # Install powerlevel10k
              plugins = with pkgs; [
                {
                  name = "powerlevel10k";
                  src = zsh-powerlevel10k;
                  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                }
                {
                  name = "zsh-nix-shell";
                  file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
                  src = zsh-nix-shell;
                }
              ];
            };
          };

          home.file = {
            # Add zsh theme to zsh directory
            ".config/zsh/zsh-theme.zsh".source = configs/zsh-theme.zsh;

            # Add btop config
            ".config/btop/btop.conf".source = configs/btop.conf;

            # Add tmux
            ".config/tmux/tmux.conf".source = configs/tmux.conf;

            ".config/tmux/tpm" = {
              source = pkgs.tpm;
              recursive = true;
            };

            # Add celluloid config file
            ".config/celluloid" = mkIf (!cfg.hardware.devices.server.enable) {
              source = configs/celluloid;
              recursive = true;
            };

            # Avoid file not found errors for bash
            ".bashrc".text = "";
          };

          # Set celluloid config file path
          dconf.settings = mkIf (!cfg.hardware.devices.server.enable) {
            "io/github/celluloid-player/celluloid" = {
              mpv-config-file = "file:///home/${username}/.config/celluloid/celluloid.conf";
            };

            "io/github/celluloid-player/celluloid" = {
              mpv-config-enable = true;
            };

            "io/github/celluloid-player/celluloid" = {
              always-append-to-playlist = true;
            };
          };
        };
      }
    ) users;
}
