{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Boot ──
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ──
  networking.hostName = "eitaar-nix";
  networking.networkmanager.enable = true;

  # ── Nix ──
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 1;
  nix.settings.builders-use-substitutes = true;
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders = @/etc/nix/machines
  '';
  nix.buildMachines = [{
    hostName = "10.87.83.25";
    system = "x86_64-linux";
    sshUser = "root";
    sshKey = "/root/.ssh/nix-builder";
    maxJobs = 8;
    speedFactor = 3;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
  }];

  programs.ssh.extraConfig = ''
    Host 10.87.83.25
      Port 2222
  '';

  # ── Time & Locale ──
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # ── Input Method (fcitx5 + Mozc) ──
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "gb";
          DefaultIM = "keyboard-gb";
        };
        "Groups/0/Items/0".Name = "keyboard-gb";
        "Groups/0/Items/1".Name = "mozc";
      };
    };
  };

  # ── Keyboard & Console ──
  console.keyMap = "uk";
  services.xserver.enable = false;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # ── Sound (PipeWire) ──
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Bluetooth ──
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ── Printing ──
  services.printing.enable = true;

  # ── SSH ──
  services.openssh.enable = true;

  # ── Users ──
  users.users."eitaar" = {
    isNormalUser = true;
    description = "eitaar";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # ── Programs ──
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.helium = {
    enable = true;
    flags = [ "--ozone-platform-hint=auto" ];
  };

  # ── Packages ──
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    bottles
    claude-code
    nodejs
    ffmpeg
    swappy
    hyprshot
  ];

  # ── Environment ──
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake /etc/nixos#eitaar-nix";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };

  # ── Fonts ──
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    antialias = true;
    defaultFonts = {
      sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK JP" ];
      emoji = [ "Noto Color Emoji" ];
    };
    hinting = {
      enable = true;
      style = "full";
    };
    subpixel = {
      rgba = "none";
      lcdfilter = "none";
    };
  };

  # ── Login Manager (ReGreet) ──
  programs.regreet = {
    enable = true;
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    cursorTheme = {
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
    };
    settings = {
      background = {
        path = "${./wallpaper.png}";
        fit = "Cover";
      };
      skip_selection = true;
      GTK.application_prefer_dark_theme = true;
      appearance = {
        greeting_msg = "";
        clock.format = "%H:%M";
      };
    };
    extraCss = ''
      window, window.background {
        background-color: transparent;
      }

      box, frame, grid {
        background-color: transparent;
        border: none;
        box-shadow: none;
      }

      frame.background {
        background-color: rgba(18, 18, 18, 0.72);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 24px;
        padding: 36px 40px;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.5);
      }

      label {
        color: rgba(255, 255, 255, 0.90);
      }

      #message_label {
        font-size: 1px;
        color: transparent;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      entry {
        background: rgba(255, 255, 255, 0.06);
        color: #fff;
        border: 1px solid rgba(255, 255, 255, 0.10);
        border-radius: 14px;
        padding: 10px 18px;
        min-height: 20px;
        box-shadow: none;
      }

      entry:focus {
        background: rgba(255, 255, 255, 0.10);
        border-color: rgba(255, 255, 255, 0.28);
        box-shadow: none;
      }

      passwordentry {
        background: rgba(255, 255, 255, 0.06);
        color: #fff;
        border: 1px solid rgba(255, 255, 255, 0.10);
        border-radius: 14px;
        padding: 6px 18px;
        min-height: 20px;
        box-shadow: none;
      }

      passwordentry:focus-within {
        background: rgba(255, 255, 255, 0.10);
        border-color: rgba(255, 255, 255, 0.28);
        box-shadow: none;
      }

      passwordentry entry {
        background: transparent;
        border: none;
        box-shadow: none;
      }

      combobox button.combo {
        background: rgba(255, 255, 255, 0.06);
        color: rgba(255, 255, 255, 0.85);
        border: 1px solid rgba(255, 255, 255, 0.10);
        border-radius: 14px;
        box-shadow: none;
        min-height: 20px;
      }

      combobox button.combo:hover {
        background: rgba(255, 255, 255, 0.10);
        border-color: rgba(255, 255, 255, 0.18);
      }

      popover contents {
        background-color: rgba(18, 18, 18, 0.94);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 14px;
      }

      button.suggested-action {
        background: rgba(255, 255, 255, 0.10);
        color: rgba(255, 255, 255, 0.92);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 14px;
        padding: 10px 28px;
        font-weight: bold;
        min-height: 20px;
        box-shadow: none;
      }

      button.suggested-action:hover {
        background: rgba(255, 255, 255, 0.18);
        border-color: rgba(255, 255, 255, 0.16);
        box-shadow: none;
      }

      button.suggested-action:active {
        background: rgba(255, 255, 255, 0.06);
      }

      button#cancel_button, button.flat {
        background: transparent;
        color: rgba(255, 255, 255, 0.28);
        border: none;
        box-shadow: none;
        font-size: 9px;
      }

      button#cancel_button:hover, button.flat:hover {
        color: rgba(255, 255, 255, 0.55);
      }

      button.destructive-action {
        background: transparent;
        color: rgba(255, 255, 255, 0.32);
        border: none;
        box-shadow: none;
        padding: 6px 14px;
        font-size: 9px;
      }

      button.destructive-action:hover {
        color: rgba(255, 255, 255, 0.60);
      }

      button.destructive-action:active {
        color: rgba(255, 255, 255, 0.45);
      }

      togglebutton {
        background: rgba(255, 255, 255, 0.05);
        color: rgba(255, 255, 255, 0.38);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 14px;
        min-height: 16px;
        box-shadow: none;
        font-size: 9px;
      }

      togglebutton:checked {
        background: rgba(255, 255, 255, 0.12);
        color: rgba(255, 255, 255, 0.88);
        border-color: rgba(255, 255, 255, 0.10);
      }

      #clock_frame label {
        font-size: 56px;
        font-weight: 300;
        color: rgba(255, 255, 255, 0.96);
      }

      infobar {
        background: rgba(0, 0, 0, 0.35);
        color: rgba(255, 255, 255, 0.82);
        border-radius: 14px;
        border: none;
      }

      #notif_info {
        background-color: rgba(255, 255, 255, 0.04);
        color: rgba(255, 255, 255, 0.80);
        border-radius: 10px;
        border: none;
      }
    '';
  };

  system.stateVersion = "26.05";
}
