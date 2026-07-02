{
  description = "eitaar's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    shojiwm.url = "github:bea4dev/ShojiWM";
    astal.url = "github:aylur/astal";
    ags.url = "github:aylur/ags";
    xwayland-satellite-shojiwm.url = "github:bea4dev/xwayland-satellite/shojiwm";
  };

  outputs = inputs@{
    self, nixpkgs, home-manager, helium-browser,
    shojiwm, xwayland-satellite-shojiwm, ags, astal, ...
  }: {
    nixosConfigurations.eitaar-nix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        # SF Pro for hyprlock (and anything else); Apple's official
        # font DMGs repackaged, not in nixpkgs for licensing reasons
        { fonts.packages = [ inputs.apple-fonts.packages.x86_64-linux.sf-pro ]; }
        inputs.silentSDDM.nixosModules.default
        {
          programs.silentSDDM = {
            enable = true;
            theme = "default";
            backgrounds.wallpaper = ./wallpaper2.png;
            profileIcons.eitaar = ./avatar.png;
            settings = {
              General = {
                enable-animations = true;
                background-fill-mode = "fill";
              };

              # macOS: sharp wallpaper on lock, big clock
              LockScreen = {
                background = "wallpaper2";
                blur = 0;
              };
              "LockScreen.Clock" = {
                format = "HH:mm";
                font-family = "Inter";
                font-size = 130;
                font-weight = 700;
                color = "#FFFFFF";
              };
              "LockScreen.Date" = {
                locale = "ja_JP";
                format = "M月d日 dddd";
                font-family = "Inter";
                font-size = 21;
                font-weight = 600;
                color = "#FFFFFF";
              };
              "LockScreen.Message" = {
                text = "キーを押してください";
                font-family = "Inter";
                font-size = 12;
              };

              # macOS: heavily blurred wallpaper behind login
              LoginScreen = {
                background = "wallpaper2";
                blur = 64;
              };
              "LoginScreen.LoginArea.Avatar" = {
                shape = "circle";
                active-size = 128;
                inactive-size = 86;
                inactive-opacity = 0.5;
              };
              "LoginScreen.LoginArea.Username" = {
                font-family = "Inter";
                font-size = 19;
                font-weight = 500;
                margin = 12;
              };
              # capsule password field, no icon (like macOS)
              "LoginScreen.LoginArea.PasswordInput" = {
                width = 240;
                height = 36;
                display-icon = false;
                font-family = "Inter";
                font-size = 14;
                background-color = "#FFFFFF";
                background-opacity = 0.25;
                border-radius-left = 18;
                border-radius-right = 18;
                masked-character = "•";
              };
              "LoginScreen.LoginArea.LoginButton" = {
                hide-if-not-needed = true;
                icon-size = 18;
                background-opacity = 0.25;
                border-radius-left = 18;
                border-radius-right = 18;
                font-family = "Inter";
              };
              "LoginScreen.LoginArea.Spinner" = {
                text = "ログイン中";
                font-family = "Inter";
              };

              # bottom bar: power center (like macOS), session picker subtle
              "LoginScreen.MenuArea.Power".position = "bottom-center";
              "LoginScreen.MenuArea.Layout".display = false;
              "LoginScreen.MenuArea.Keyboard".display = false;
              "LoginScreen.MenuArea.Session" = {
                position = "bottom-left";
                display-session-name = false;
                button-width = 40;
              };

              Tooltips.font-family = "Inter";
            };
          };
        }
        helium-browser.nixosModules.default
        shojiwm.nixosModules.default
        {
          programs.shojiwm = {
            enable = true;
            initConfig = {
              enable = true;
              users = [ "eitaar" ];
            };
            xwaylandSatellite.package =
              xwayland-satellite-shojiwm.packages.x86_64-linux.default;
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.eitaar = import ./home.nix;
        }
      ];
    };
  };
}
