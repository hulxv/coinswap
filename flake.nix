{
  description = "A Nix flake for the Coinswap Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        packages = {
          coinswap = naersk-lib.buildPackage {
            pname = "coinswap";
            version = "0.1.0";
            src = ./.;

            # build dependencies from Cargo.toml
            nativeBuildInputs = with pkgs; [
              pkg-config
            ];

            # system dependencies from Cargo.toml
            buildInputs = with pkgs; [
              openssl
              tor
              bitcoin
            ];

            # rust-toolchain.toml specifies the stable channel
            # rustc = pkgs.rust-bin.stable.latest.default;

            # the project has three binary targets defined in src/bin/
            # we want to build all of them
            cargoBuildFlags = [ "--bin makerd" "--bin maker-cli" "--bin taker" ];
          };
          default = self.packages.${system}.coinswap;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            # rust toolchain
            pkgs.rust-bin.stable.latest.default
            pkgs.cargo
            pkgs.rustfmt
            pkgs.clippy

            # other dependencies
            pkgs.tor
            pkgs.openssl
            pkgs.pkg-config
            pkgs.bitcoin
          ];
        };
      });
}