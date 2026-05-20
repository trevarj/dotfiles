{
  stdenv,
  fetchurl,
  makeWrapper,
  fzf,
  ripgrep,
}:
stdenv.mkDerivation rec {
  pname = "opencode";
  version = "1.14.19";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
    sha256 = "0h0ljmkz26ab02is0yq8balw9x6229mkb8prdwmjxj0frqiigccc";
  };

  nativeBuildInputs = [makeWrapper];
  sourceRoot = ".";

  installPhase = ''
    install -Dm755 opencode "$out/bin/opencode"
    wrapProgram "$out/bin/opencode" \
      --prefix PATH : "${fzf}/bin:${ripgrep}/bin" \
      --set OPENCODE_DISABLE_UPDATE 1
  '';

  meta = {
    description = "Open source AI coding agent for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
  };
}
