{
  description = "Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "rustfmt"
            "clippy"
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo
            rustc

            pkg-config

            autoreconfHook
            gnumake
            gcc
            libtool
            m4

            libxkbcommon
            wayland
            wayland-protocols
            libevdev

            libX11
            libXcursor
            libXrandr
            libXi
            libXext

            fontconfig
            freetype
            libGL
            vulkan-loader
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
            wayland
            libxkbcommon
            libGL
            vulkan-loader
            libX11
            libXcursor
            libXrandr
            libXi
            libXext
          ]);

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [
              wayland
              libxkbcommon
              libGL
              vulkan-loader
              libX11
              libXcursor
              libXrandr
              libXi
              libXext
            ])}:$LD_LIBRARY_PATH"
            export RUST_SRC_PATH="${rustToolchain}/lib/rustlib/src/rust/library"
            rustc --version
            cargo --version
          '';
        };
      }
    );
}
