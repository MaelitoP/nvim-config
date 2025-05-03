{
  description = "MaelitoP's Neovim configuration (nixified)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "nvim-config";
          src = self;
          installPhase = ''
            mkdir -p $out
            cp -r * $out/
          '';
        };

        homeManagerModules.nvim-config = { config, ... }: {
          home.file.".config/nvim".source = self.outPath;
        };
      });
}
