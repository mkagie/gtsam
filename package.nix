{ src
, stdenv
, cmake
, pkg-config
, boost
, tbb
}:
stdenv.mkDerivation {
  pname = "gtsam";
  version = "4.2";
  inherit src;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost
    # TODO(mkagie) Why is this not registering with cmake?
    tbb
  ];
}
