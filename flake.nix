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
            inputsFrom = [ gtsam-py ];
            packages = with pkgs; [
              clang
              cmakeCurses
            ];
          };

          python = pkgs.mkShell rec {
            name = "gtsam-2";
            inputsFrom = [ gtsam ];
            buildInputs = with pkgs; [
              libz
            ];
            packages = with pkgs; [
              python3
              python3.pkgs.pip
              python3.pkgs.virtualenv
            ];
            shellHook = ''
              VENV_DIR="venv"

              # Check if the virtual environment exists
              if [ -d "$VENV_DIR" ]; then
                  echo "Activating existing virtual environment..."
                  source "$VENV_DIR/bin/activate"
              else
                  echo "Creating virtual environment..."
                  virtualenv "$VENV_DIR"

                  # Check if the virtual environment creation was successful
                  if [ $? -eq 0 ]; then
                      echo "Virtual environment created successfully. Activating..."
                      source "$VENV_DIR/bin/activate"

                      echo "Installing required pacakges"
                      pip install --upgrade pip setuptools
                      pip install -r python/dev_requirements.txt
                      pip install -r python/requirements.txt

                      if [ -e "build/python/setup.py" ]; then
                        echo "Installing gtsam"
                        cd build && make python-install
                        cd ..
                      else
                        echo "Error: No GTSAM to install -- try building it"
                      fi
                  else
                      echo "Error: Failed to create virtual environment."
                  fi
              fi
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
              export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
            '';
          };
        };
      }
    );
}
