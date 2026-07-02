{ config, pkgs, inputs, ... }:

{
  home.username = "eitaar";
  home.homeDirectory = "/home/eitaar";
  home.stateVersion = "24.11";

  imports = [ inputs.ags.homeManagerModules.default ];

  # ── Packages ──
  home.packages = with pkgs; [
    # CLI
    ripgrep
    fd
    eza
    btop
    fastfetch

    # GUI
    kitty
    zed-editor
    vscode
    discord
  ];

  # ── Cursor ──
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
  };

  # ── AGS ──
  programs.ags = {
    enable = true;
    extraPackages = with inputs.astal.packages.${pkgs.system}; [
      apps
      battery
      mpris
      network
      notifd
      powerprofiles
      tray
      wireplumber
      pkgs.fzf
    ];
  };

  # ── Zsh ──
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#eitaar-nix";
      steam = "steam -cef-disable-gpu -cef-disable-gpu-compositing";
    };
  };

  # ── Kitty ──
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      background_opacity = "0.5";
      confirm_os_window_close = 0;
      window_padding_width = 8;

      # Catppuccin Mocha
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";
      color0 = "#45475a";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#cba6f7";
      color6 = "#94e2d5";
      color7 = "#bac2de";
    };
  };

  # ── Notifications ──
  services.mako.enable = false;

  # ── Screen lock (hyprlock + hypridle) ──
  programs.hyprlock = {
    enable = true;
    # macOS Sonoma lock screen, sized for 1920x1080: small date line
    # ABOVE a huge bold clock (Sonoma/iOS order), SF Pro Display
    # throughout, compact login cluster near the bottom. Kanji in the
    # date falls back to Noto Sans CJK, same idea as SF+Hiragino on
    # real macOS. Weights via pango markup — "SF Pro Display Bold" is
    # not a fontconfig family name.
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [{
        monitor = "";
        path = "/etc/nixos/wallpaper2.png";
        blur_passes = 2;
        blur_size = 8;
      }];

      label = [
        # bold clock on top
        {
          monitor = "";
          text = "<b>$TIME</b>";
          font_size = 96;
          font_family = "SF Pro Display";
          color = "rgba(255, 255, 255, 0.95)";
          position = "0, -96";
          halign = "center";
          valign = "top";
        }
        # date, small, under the clock
        {
          monitor = "";
          text = ''cmd[update:60000] LC_TIME=ja_JP.UTF-8 date +"<span weight='600'>%-m月%-d日 %A</span>"'';
          font_size = 16;
          font_family = "SF Pro Display";
          color = "rgba(255, 255, 255, 0.9)";
          position = "0, -228";
          halign = "center";
          valign = "top";
        }
        # username under the avatar
        {
          monitor = "";
          text = "<span weight='500'>$USER</span>";
          font_size = 18;
          font_family = "SF Pro Display";
          color = "rgb(ffffff)";
          position = "0, 205";
          halign = "center";
          valign = "bottom";
        }
      ];

      image = [{
        monitor = "";
        path = "${config.home.homeDirectory}/Pictures/icon.png";
        size = 128;
        rounding = -1;
        border_size = 0;
        position = "0, 232";
        halign = "center";
        valign = "bottom";
      }];

      # translucent pill, macOS login style
      input-field = [{
        monitor = "";
        size = "240, 36";
        outline_thickness = 0;
        rounding = 18;
        placeholder_text = ''<span font_family="SF Pro Display" foreground="##ffffffbb">パスワードを入力</span>'';
        font_family = "SF Pro Display";
        font_color = "rgb(ffffff)";
        inner_color = "rgba(255, 255, 255, 0.25)";
        check_color = "rgba(255, 255, 255, 0.35)";
        fail_color = "rgba(255, 90, 90, 0.45)";
        dots_size = 0.28;
        dots_spacing = 0.3;
        fade_on_empty = false;
        position = "0, 152";
        halign = "center";
        valign = "bottom";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings.general = {
      lock_cmd = "pidof hyprlock || hyprlock";
      before_sleep_cmd = "loginctl lock-session";
    };
  };

  # ShojiWM doesn't integrate with systemd, so graphical-session.target
  # (which hypridle hangs off) never activates on its own, and it refuses
  # manual starts. This startable session target pulls it in via BindsTo;
  # the shojiwm config starts it on session startup.
  systemd.user.targets.shojiwm-session = {
    Unit = {
      Description = "ShojiWM compositor session";
      BindsTo = [ "graphical-session.target" ];
    };
  };
}
