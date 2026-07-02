{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Boot ──
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 0;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ──
  networking.hostName = "eitaar-nix";
  networking.networkmanager.enable = true;

  # ── Nix ──
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 1;
  nix.distributedBuilds = true;
  services.udisks2.enable = true;
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

  programs.steam = {
    enable = true; 
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
    kdePackages.dolphin
    gamescope
  ];

  # ── Environment ──
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake /etc/nixos#eitaar-nix";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    XCURSOR_SIZE = "24";
  };

  # ── Fonts ──
  fonts = {
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "none";
      subpixel.lcdfilter = "none";

      defaultFonts = {
        sansSerif = [ "Noto Sans" "Noto Sans CJK JP" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Serif CJK JP" "Noto Color Emoji" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans CJK JP" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ── Login Manager (SDDM) ──
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  system.stateVersion = "26.05";
}
