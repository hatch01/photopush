{
  description = "photopush - Flutter + Serverpod development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
          pkgs,
          system,
          lib,
          ...
        }:
        let
          # Re-import nixpkgs with the config required for the Android SDK.
          pkgs = import nixpkgs {
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

          # Keep Serverpod CLI out of the Nix store and pin it for reproducibility.
          serverpodVersion = "4.0.3";
          serverpodHome = ".serverpod-cli";
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
              pkg-config
              gtk3
              glib
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

              # Web target
              chromium
            ];

            CHROME_EXECUTABLE = lib.getExe pkgs.chromium;
            FLUTTER_SDK = "${pkgs.flutter}";

            ANDROID_HOME = androidSdkPath;
            ANDROID_SDK_ROOT = androidSdkPath;
            ANDROID_NDK_ROOT = "${androidSdkPath}/ndk-bundle";
            ANDROID_AVD_HOME = "${PWD}/.android/avd";

            GRADLE_OPTS = ''
              -Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdkPath}/build-tools/34.0.0/aapt2
              -Djava.net.preferIPv4Stack=true
            '';

            shellHook = ''
              # Serverpod CLI is not packaged in nixpkgs. It is installed on
              # first shell load into a project-local PUB_CACHE so it never
              # collides with a global install or the project's own cache.
              if [ ! -x "${serverpodHome}/bin/serverpod" ]; then
                echo "serverpod: installing CLI ${serverpodVersion} (first run only)..." >&2
                PUB_CACHE="${serverpodHome}" dart pub global activate \
                  serverpod_cli "${serverpodVersion}" >&2
              fi
              export PATH="${serverpodHome}/bin:$PATH"
            '';
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
