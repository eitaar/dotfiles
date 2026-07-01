# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "eitaar-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.buildMachines = [{
    hostName = "10.87.83.25";
    system = "x86_64-linux";
    sshUser = "root";
    sshKey = "/root/.ssh/nix-builder";
    maxJobs = 8;
    speedFactor = 3;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
  }];
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.extraOptions = ''
    builders = @/etc/nix/machines
  '';
  programs.ssh.extraConfig = ''
    Host 10.87.83.25
      Port 2222
  '';
  # Set your time zone.
  time.timeZone = "Europe/London";
  # Select internationalisation properties.
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

  i18n.inputMethod = {
   enable = true;
   type = "fcitx5";
   fcitx5 = {
    waylandFrontend = true;
    addons = with pkgs; [
     fcitx5-mozc
     fcitx5-gtk
    ];
   };
  };

  i18n.inputMethod.fcitx5.settings.inputMethod = {
  GroupOrder."0" = "Default";
  "Groups/0" = {
    Name = "Default";
    "Default Layout" = "gb";
    DefaultIM = "keyboard-gb";
  };
  "Groups/0/Items/0".Name = "keyboard-gb";
  "Groups/0/Items/1".Name = "mozc";
};
i18n.inputMethod.fcitx5.ignoreUserConfig = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  users.users."eitaar" = {
    isNormalUser = true;
    description = "eitaar";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.helium = {
    enable = true;
    flags = [ "--ozone-platform-hint=auto" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake /etc/nixos#eitaar-nix";
  };
  environment.sessionVariables =  {
    NIXOS_OZONE_WL = "1";
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };

  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  git
  bottles
  claude-code
  nodejs
  ffmpeg
  swappy
  hyprshot
  ];

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

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK JP" ];
      emoji = [ "Noto Color Emoji" ];
    };
    subpixel = {
      rgba = "none";
      lcdfilter = "none";
    };
    hinting = {
      enable = true;
      style = "slight";
    };
    antialias = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.max-jobs = 1;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
