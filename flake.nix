{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        gtsam = pkgs.stdenv.mkDerivation {
          pname = "gtsam";
          version = "4.2";
          src = pkgs.lib.cleanSource ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            boost
            # TODO(mkagie) why is this not registering with cmake
            tbb
          ];
        };

        # Create python bindings
        gtsam-py = pkgs.python3Packages.toPythonModule (gtsam.overrideAttrs (old: {
          pname = old.pname + "-py";
          # Add python to buildInputs
          buildInputs = old.buildInputs ++ [ pkgs.python3.pkgs.pybind11 ];
          # Add cmakeFlags
          cmakeFlags = (old.cmakeFlags or [ ]) ++ [
            # TODO(mkagie) remove this when no longer needed
            "-DGTSAM_WITH_TBB=OFF"
            "-DGTSAM_BUILD_PYTHON=1"
            "-DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF"
            "-DGTSAM_BUILD_TESTS=OFF"
          ];

          propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ (with pkgs.python3.pkgs; [
            pyparsing
            numpy
            pytest
            pybind11
          ]);

          # outputs = [ "out" "python" ];

          nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.patchelf ];

          postInstall = ''
            cp -r python $out
            patchelf --shrink-rpath --allowed-rpath-prefixes /nix/store $out/python/gtsam_unstable/gtsam_unstable.cpython-311-x86_64-linux-gnu.so
            patchelf --shrink-rpath --allowed-rpath-prefixes /nix/store $out/python/gtsam/gtsam.cpython-311-x86_64-linux-gnu.so
          '';
        }));
      in
      {
        packages = {
          default = gtsam;
          inherit gtsam gtsam-py;
        };
        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [ gtsam ];
            packages = with pkgs; [
              clang
              cmakeCurses
            ];
          };
          python = (pkgs.buildFHSUserEnv {
            name = "gtsam";
            targetPkgs = pkgs: (with pkgs; [
              python3
              python3.pkgs.pip
              python3.pkgs.virtualenv
            ]);
          }).env;
        };
      }
    );
}
