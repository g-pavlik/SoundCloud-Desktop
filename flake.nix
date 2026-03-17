{
  description = "SoundCloud Desktop - unofficial SoundCloud client built with Tauri 2 + React";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        buildInputs = with pkgs; [
          webkitgtk_4_1
          gtk3
          glib
          glib-networking
          libsoup_3
          cairo
          pango
          gdk-pixbuf
          atk
          harfbuzz
          alsa-lib
          openssl
          dbus
          librsvg
          libayatana-appindicator
        ];

        nativeBuildInputs = with pkgs; [
          cargo
          rustc
          cargo-tauri
          pkg-config
          nodejs_22
          pnpm_10
          pnpmConfigHook
          wrapGAppsHook3
          gobject-introspection
        ];

      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "soundcloud-desktop";
          version = "5.9.0";

          src = ./.;

          inherit nativeBuildInputs buildInputs;

          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit pname version;
            src = ./desktop;
            fetcherVersion = 3;
            hash = "sha256-xt3DDTqcgDX+e54HSIej/n4S3PdlDrYiYlVsY5oUtZg=";
          };

          # pnpmConfigHook expects pnpmRoot
          pnpmRoot = "desktop";

          cargoDeps = pkgs.rustPlatform.importCargoLock {
            lockFile = ./desktop/src-tauri/Cargo.lock;
            allowBuiltinFetchGit = true;
          };

          postUnpack = ''
            export cargoDepsCopy=$(cp -r ${cargoDeps} $TMPDIR/cargo-deps && echo $TMPDIR/cargo-deps)
            chmod -R +w $cargoDepsCopy
          '';

          configurePhase = ''
            runHook preConfigure

            # Setup cargo vendor
            mkdir -p desktop/src-tauri/.cargo
            cat > desktop/src-tauri/.cargo/config.toml << CARGO_EOF
            [source.crates-io]
            replace-with = "vendored-sources"

            [source.vendored-sources]
            directory = "$cargoDepsCopy"
            CARGO_EOF

            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild

            export HOME=$TMPDIR
            export WEBKIT_DISABLE_COMPOSITING_MODE=1

            # Build frontend
            cd desktop
            pnpm run build
            cd ..

            # Build Tauri/Rust binary
            cd desktop/src-tauri
            cargo build --release --frozen --features tauri/custom-protocol
            cd ../..

            runHook postBuild
          '';

          preFixup = ''
            gappsWrapperArgs+=(
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libayatana-appindicator ]}"
            )
          '';

          installPhase = ''
            runHook preInstall

            # Install binary
            install -Dm755 desktop/src-tauri/target/release/soundcloud-desktop $out/bin/soundcloud-desktop

            # Install desktop entry
            mkdir -p $out/share/applications
            cat > $out/share/applications/soundcloud-desktop.desktop << 'DESKTOP_EOF'
            [Desktop Entry]
            Name=SoundCloud Desktop
            Comment=Unofficial SoundCloud Desktop Client
            Exec=soundcloud-desktop
            Icon=soundcloud-desktop
            Terminal=false
            Type=Application
            Categories=Audio;Music;Player;
            DESKTOP_EOF

            # Install icons
            for size in 32 128 256; do
              mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
            done
            cp desktop/src-tauri/icons/32x32.png $out/share/icons/hicolor/32x32/apps/soundcloud-desktop.png
            cp desktop/src-tauri/icons/128x128.png $out/share/icons/hicolor/128x128/apps/soundcloud-desktop.png
            cp "desktop/src-tauri/icons/128x128@2x.png" $out/share/icons/hicolor/256x256/apps/soundcloud-desktop.png

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Unofficial SoundCloud desktop client";
            homepage = "https://github.com/zxcloli666/SoundCloud-Desktop";
            license = licenses.mit;
            mainProgram = "soundcloud-desktop";
            platforms = platforms.linux;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rust-analyzer
            cargo-tauri
            pkg-config
            nodejs_22
            pnpm_10
          ];

          shellHook = ''
            export GIO_MODULE_PATH="${pkgs.glib-networking}/lib/gio/modules"
          '';
        };
      });
}
