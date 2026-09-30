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
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
