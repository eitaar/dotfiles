{ config, pkgs, ... }:

{
  home.username = "eitaar";
  home.homeDirectory = "/home/eitaar";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # CLI
    ripgrep fd eza btop fastfetch

    # Hyprland周辺
    wofi              # アプリランチャー
    grim              # スクリーンショット
    slurp             # 範囲選択
    wl-clipboard      # クリップボード
    awww              # 壁紙
    pavucontrol       # 音量GUI
    networkmanagerapplet  # Wi-Fi
    brightnessctl     # 明るさ調整
    playerctl         # メディアキー
    libnotify         # notify-send コマンド
    hyprpicker        # カラーピッカー

    # アプリ
    firefox
    kitty
    nautilus          # ファイルマネージャ
  ];

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
    };
  };

  # ── Hyprland ──
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";

      monitor = ",preferred,auto,1";

      # 起動時に実行
      exec-once = [
        "fcitx5 -d"
        "awww-daemon"
        "waybar"
        "mako"
        "nm-applet --indicator"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(89b4fa) rgb(cba6f7) 45deg";
        "col.inactive_border" = "rgb(313244)";
        layout = "dwindle";
        resize_on_border = true;
        hover_icon_on_border = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
          xray = false;
        };
        shadow = {
          enabled = true;
          range = 15;
          render_power = 3;
          color = "rgba(1a1a2eee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "ease, 0.25, 0.1, 0.25, 1"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "smooth, 0.5, 0, 0.99, 0.99"
        ];
        animation = [
          "windows, 1, 4, ease, slide"
          "windowsOut, 1, 4, ease, slide"
          "windowsMove, 1, 3, smooth"
          "fade, 1, 4, ease"
          "workspaces, 1, 4, ease, slide"
          "specialWorkspace, 1, 4, overshot, slidevert"
        ];
      };

      input = {
        kb_layout = "gb";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          drag_lock = true;
        };
      };

      dwindle = {
        preserve_split = true;
        smart_split = false;
        smart_resizing = true;
      };

      # ── その他 ──
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };

      # ── グループ（タブ化ウィンドウ） ──
      group = {
        "col.border_active" = "rgb(89b4fa)";
        "col.border_inactive" = "rgb(45475a)";
        groupbar = {
          font_family = "JetBrainsMono Nerd Font";
          font_size = 10;
          height = 20;
          "col.active" = "rgb(89b4fa)";
          "col.inactive" = "rgb(313244)";
          text_color = "rgb(cdd6f4)";
        };
      };

      # ── ワークスペースルール ──
      workspace = [
        "5, defaultFloat:true"
      ];

      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #  キーバインド
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      bind = [
        # ── 基本操作 ──
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod SHIFT, M, exit"
        "$mod, E, exec, nautilus"
        "$mod, Space, exec, $menu"
        "$mod, F, fullscreen, 0"
        "$mod SHIFT, F, fullscreen, 1"

        # ── フローティング操作 ──
        "$mod, V, togglefloating"
        "$mod, C, centerwindow"
        "$mod, P, pin"

        # ── フォーカス移動 ──
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, Tab, cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"

        # ── ウィンドウ移動 ──
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # ── dwindle レイアウト操作 ──
        "$mod, S, layoutmsg, togglesplit"

        # ── グループ（タブ化） ──
        "$mod, G, togglegroup"
        "$mod, N, changegroupactive, f"
        "$mod SHIFT, N, changegroupactive, b"

        # ── リサイズモード（Submap） ──
        "$mod, R, submap, resize"

        # ── スペシャルワークスペース（スクラッチパッド） ──
        "$mod, grave, togglespecialworkspace, scratchpad"
        "$mod SHIFT, grave, movetoworkspace, special:scratchpad"

        # ── ワークスペース切替 ──
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # ── ウィンドウをワークスペースへ移動 ──
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # ── スクリーンショット ──
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim - | wl-copy"

        # ── カラーピッカー ──
        "$mod SHIFT, C, exec, hyprpicker -a"

        # ── マウスでワークスペーススクロール ──
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      # ── マウスでウィンドウ操作 ──
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ── メディアキー・音量（リピート可能） ──
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonitorBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonitorBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };

    # ── リサイズ Submap ──
    extraConfig = ''
      submap = resize
      binde = , right, resizeactive, 40 0
      binde = , left, resizeactive, -40 0
      binde = , up, resizeactive, 0 -40
      binde = , down, resizeactive, 0 40
      binde = SHIFT, right, resizeactive, 100 0
      binde = SHIFT, left, resizeactive, -100 0
      binde = SHIFT, up, resizeactive, 0 -100
      binde = SHIFT, down, resizeactive, 0 100
      bind = , escape, submap, reset
      bind = , Return, submap, reset
      submap = reset
    '';
  };

  # ── Waybar ──
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      spacing = 8;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "一";
          "2" = "二";
          "3" = "三";
          "4" = "四";
          "5" = "五";
          "active" = "";
          "default" = "";
        };
        persistent-workspaces = {
          "*" = 5;
        };
      };

      clock = {
        format = "{:%H:%M  %a %d %b}";
        tooltip-format = "{:%Y-%m-%d}";
      };

      battery = {
        format = "{icon}  {capacity}%";
        format-icons = [ "󰂎" "󰁼" "󰁾" "󰂀" "󰁹" ];
      };

      pulseaudio = {
        format = "󰕾  {volume}%";
        format-muted = "󰖁  mute";
        on-click = "pavucontrol";
      };

      network = {
        format-wifi = "󰖩  {signalStrength}%";
        format-disconnected = "󰖪  off";
        tooltip-format-wifi = "{essid}";
      };

      tray.spacing = 10;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        color: #cdd6f4;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        border-bottom: 2px solid rgba(137, 180, 250, 0.3);
      }

      #workspaces button {
        padding: 0 8px;
        color: #6c7086;
        border-bottom: 2px solid transparent;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
      }

      #workspaces button:hover {
        color: #b4befe;
        background: rgba(137, 180, 250, 0.1);
      }

      #clock, #battery, #pulseaudio, #network {
        padding: 0 12px;
      }

      #battery.warning {
        color: #f9e2af;
      }

      #battery.critical {
        color: #f38ba8;
      }
    '';
  };

  # ── Kitty ──
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      background_opacity = "0.85";
      confirm_os_window_close = 0;
      window_padding_width = 8;

      # Catppuccin Mocha カラー
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

  # ── 通知 ──
  services.mako = {
    enable = true;
    settings = {
      border-radius = 8;
      border-size = 2;
      border-color = "#89b4fa";
      background-color = "#1e1e2eee";
      text-color = "#cdd6f4";
      default-timeout = 5000;
      font = "JetBrainsMono Nerd Font 11";
    };
  };
}
