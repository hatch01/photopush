{
  description = "photopush - Flutter + Serverpod development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

    # serverpod_cli 3.4.13 -> 4.0.3, not in nixpkgs-unstable yet.
    # Pinned to the commit so the patch never changes under our feet.
    nixpkgs-patch-serverpod-cli-bump = {
      url = "https://github.com/NixOS/nixpkgs/commit/10c3b3443933fd84f9832fd03308a3f4ad7789ba.diff";
      flake = false;
    };
  };

  nixConfig = {
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        {
          system,
          lib,
          ...
        }:
        let
          # Re-import the patched nixpkgs with the config required for the
          # Android SDK.
          nixpkgsPatched = inputs.nixpkgs-patcher.lib.patchNixpkgs {
            inherit inputs system;
            inherit (inputs) nixpkgs;
          };

          pkgs = import nixpkgsPatched {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };

          androidComposition = pkgs.androidenv.composeAndroidPackages {
            cmdLineToolsVersion = "latest";
            platformToolsVersion = "latest";
            buildToolsVersions = [
              "37.0.0"
              "36.0.0"
              "35.0.0"
              "34.0.0"
              "30.0.3"
            ];
            platformVersions = [
              "37"
              "36"
              "35"
              "34"
              "33"
              "31"
            ];
            includeCmake = true;
            cmakeVersions = [ "3.22.1" ];
            includeNDK = true;
            ndkVersions = [ "28.2.13676358" ];
          };

          androidSdk = androidComposition.androidsdk;
          androidSdkPath = "${androidSdk}/libexec/android-sdk";
          PWD = builtins.getEnv "PWD";

          # The Linux app used to need `build/linux/<flutter-arch>/<mode>/bundle/lib`
          # on `LD_LIBRARY_PATH`, because the Dart VM `dlopen()`s the native
          # assets next to the app (serverpod's client-side database brings
          # `libsqlite3_connection_pool.so` and `libsqlite3.so`) by bare name and
          # the engine's RUNPATH does not mention its own directory. That is now
          # handled in `photopush_flutter/linux/CMakeLists.txt`, which adds
          # `$ORIGIN` to the engine, and it must stay that way: the bundled
          # `libsqlite3.so` is a Dart native asset that only exports the ~90
          # symbols its FFI bindings use -- no `sqlite3_bind_int` -- so leaving
          # it on `LD_LIBRARY_PATH` breaks every other process of the shell that
          # resolves `libsqlite3.so` by name (node, and with it the `gemini` CLI:
          # "node: symbol lookup error: undefined symbol: sqlite3_bind_int").

          # A view of the SDK that is identical to `pkgs.flutter` except that
          # packages/flutter_tools/.dart_tool is not linked in.
          #
          # `serverpod start` never execs the `flutter` wrapper. It reads
          # `flutterRoot` from `flutter --version --machine` and then spawns dart
          # directly on $FLUTTER_ROOT/packages/flutter_tools/bin/flutter_tools.dart.
          # That entrypoint is the *vanilla* SDK source: nixpkgs only strips the
          # artifact download out of the compiled flutter_tools.snapshot
          # (see flutter-tools.nix postPatch), so running the .dart source makes
          # the tool try to fetch engine_stamp.json into the read-only store.
          # Hiding .dart_tool trips the existence check in
          # serverpod_cli's flutter_process.dart and sends it down the supported
          # fallback, which execs the wrapper and uses the patched snapshot.
          flutterSdk = pkgs.runCommand "flutter-sdk" { } ''
            mkdir -p "$out"

            for entry in ${pkgs.flutter}/*; do
              [ "$(basename "$entry")" = packages ] || ln -s "$entry" "$out/$(basename "$entry")"
            done

            mkdir -p "$out/packages"
            for entry in ${pkgs.flutter}/packages/*; do
              [ "$(basename "$entry")" = flutter_tools ] || ln -s "$entry" "$out/packages/$(basename "$entry")"
            done

            mkdir -p "$out/packages/flutter_tools"
            for entry in ${pkgs.flutter}/packages/flutter_tools/*; do
              ln -s "$entry" "$out/packages/flutter_tools/$(basename "$entry")"
            done
          '';
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Language runtimes
              flutter
              dart

              # Workspace / tooling
              melos
              just
              protobuf
              protoc-gen-dart
              serverpod_cli

              # Serverpod runtime dependencies
              postgresql_18
              redis

              # Android / Flutter mobile
              androidSdk
              jdk17
              jdk25
              android-tools
              apksigner

              # Linux desktop build + runtime deps
              clang
              cmake
              ninja
              patchelf
              pkg-config
              gtk3
              glib
              gsettings-desktop-schemas
              adwaita-icon-theme
              pcre2
              libsecret
              libxkbcommon
              libepoxy
              at-spi2-core
              dbus
              systemd
              util-linux
              xz
              zstd
              libdeflate
              libwebp
              libgcrypt
              libgpg-error
              libselinux
              libsepol
              libthai
              libdatrie
              libxdmcp
              libxtst
              libsysprof-capture
              zenity
              libglvnd

              # In-app browser (desktop_webview_window, flutter_web_auth_2)
              # need webkit2gtk-4.1 + libsoup-3.0 at build time. nixpkgs only
              # ships the 4.1 ABI now, so these must stay in sync with it.
              # The rest are libsoup-3.0's Requires.private: CMake's FindPkgConfig
              # resolves those too and warns for each one it cannot find.
              webkitgtk_4_1
              libsoup_3
              libpsl
              brotli
              nghttp2
              sqlite

              # Web target
              chromium
            ];

            CHROME_EXECUTABLE = lib.getExe pkgs.chromium;
            FLUTTER_SDK = "${flutterSdk}";
            FLUTTER_ROOT = "${flutterSdk}";

            # The nixpkgs SDK is immutable, so there is no cache to guard.
            # bin/flutter exports this itself, but `serverpod start` does not go
            # through that wrapper: it reads `flutterRoot` from
            # `flutter --version --machine` and then spawns dart directly on
            # flutter_tools.dart. Without this it tries to create
            # $FLUTTER_ROOT/bin/cache/lockfile in the read-only store and dies
            # with "Failed to open or create the artifact cache lockfile".
            FLUTTER_ALREADY_LOCKED = "true";

            ANDROID_HOME = androidSdkPath;
            ANDROID_SDK_ROOT = androidSdkPath;
            ANDROID_NDK_ROOT = "${androidSdkPath}/ndk-bundle";
            ANDROID_AVD_HOME = "${PWD}/.android/avd";

            GRADLE_OPTS = ''
              -Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdkPath}/build-tools/34.0.0/aapt2
              -Djava.net.preferIPv4Stack=true
            '';

            # Set up XDG_DATA_DIRS so GTK/GLib file choosers and portals find GSettings schemas and icon themes
            shellHook = ''
              export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.adwaita-icon-theme}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
            '';
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
