{pkgs}: {
  default = pkgs.mkShell {
    packages = with pkgs; [
      nil
      alejandra
      statix
    ];
  };

  rust = pkgs.mkShell {
    packages = with pkgs; [
      gcc
      gnumake
      clang
      llvm
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy
      openssl
      libseccomp
      libudev-zero
      pkg-config
      nodejs
      perl
      python3
      sqlite
    ];
  };

  bitcoin = pkgs.mkShell {
    packages = with pkgs; [
      gnumake
      automake
      autoconf
      cmake
      libtool
      gcc14
      clang
      perl
      pkg-config
      python3
      qt5.qttools
      util-linux
      boost
      capnproto
      libevent
      qt5.qtbase
      sqlite
      zeromq
    ];
  };

  gcc = pkgs.mkShell {
    packages = with pkgs; [
      gnumake
      automake
      autoconf
      cmake
      libtool
      gcc
      clang
      perl
    ];
  };
}
