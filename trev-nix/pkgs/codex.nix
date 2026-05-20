{
  stdenv,
  fetchurl,
  bubblewrap,
}:
stdenv.mkDerivation rec {
  pname = "codex";
  version = "0.132.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "1cl3m36ia40fkiv66haf7wi8bg3nl8slbbbs35yisnzgwhp46r4b";
  };

  nativeBuildInputs = [bubblewrap];

  unpackPhase = ''
    tar xzf "$src"
  '';

  installPhase = ''
    install -Dm755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
  '';

  meta = {
    description = "AI coding agent from OpenAI";
    homepage = "https://github.com/openai/codex";
  };
}
