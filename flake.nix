{
  description = "A Spotify player in the terminal with full feature parity";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ rust-overlay.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        package = pkgs.callPackage ./package.nix {};
      in
      {
        packages.default = package;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            rustToolchain
            pkgs.pkg-config
            pkgs.openssl
            pkgs.dbus
            pkgs.fontconfig
            pkgs.libsixel
            pkgs.alsa-lib
            pkgs.libpulseaudio
            pkgs.portaudio
            pkgs.libjack2
            pkgs.SDL2
            pkgs.gst_all_1.gstreamer
            pkgs.gst_all_1.gst-plugins-base
            pkgs.gst_all_1.gst-plugins-good
          ];

          shellHook = ''
            export RUST_BACKTRACE=1
          '';
        };
      }
    );
}
