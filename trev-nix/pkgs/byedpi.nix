{
  stdenv,
  fetchFromGitHub,
  gcc,
}:
stdenv.mkDerivation rec {
  pname = "byedpi";
  version = "0.17.3";

  src = fetchFromGitHub {
    owner = "hufrea";
    repo = "byedpi";
    rev = "v${version}";
    sha256 = "0izhnr6rfxrpzrrhfr6zh6nyw6dccjx9xs360v4f3qmjhl42cdbl";
  };

  nativeBuildInputs = [gcc];

  configurePhase = "true";
  doCheck = false;

  makeFlags = [
    "CC=${gcc}/bin/gcc"
    "PREFIX=$(out)"
  ];

  meta = {
    description = "Local SOCKS proxy with DPI bypass methods";
    homepage = "https://github.com/hufrea/byedpi";
  };
}
