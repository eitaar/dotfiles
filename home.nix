{ config, pkgs, inputs, ... }:

{
  home.username = "eitaar";
  home.homeDirectory = "/home/eitaar";
  home.stateVersion = "24.11";
  imports = [inputs.ags.homeManagerModules.default];
  home.packages = with pkgs; [
    # CLI
    ripgrep fd eza btop fastfetch
    pkgs.zed-editor
    # アプリ
    kitty
    vscode
    discord
  ];

  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [
      inputs.astal.packages.${pkgs.system}.apps
      inputs.astal.packages.${pkgs.system}.battery
      inputs.astal.packages.${pkgs.system}.mpris
      inputs.astal.packages.${pkgs.system}.network
      inputs.astal.packages.${pkgs.system}.notifd
      inputs.astal.packages.${pkgs.system}.powerprofiles
      inputs.astal.packages.${pkgs.system}.tray
      inputs.astal.packages.${pkgs.system}.wireplumber
      fzf
    ];
  };
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
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

  # ── Electron Wayland フラグ ──
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';

  # ── 通知 ──
  # shoji-bar-2 が AstalNotifd ベースの通知ポップアップを持つため無効化
  services.mako.enable = false;
}
