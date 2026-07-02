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
}
