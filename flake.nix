{
  description = "eitaar's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    shojiwm.url = "github:bea4dev/ShojiWM";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, helium-browser, shojiwm, ... }: {
    nixosConfigurations.eitaar-nix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        helium-browser.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.eitaar = import ./home.nix;
        }
        shojiwm.nixosModules.default
        {
          programs.shojiwm = {
            enable = true;
            initConfig = {
              enable = true;
              users = [ "eitaar" ];
            };
          };
        }
      ];
    };
  };
}
