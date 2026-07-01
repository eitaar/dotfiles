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
