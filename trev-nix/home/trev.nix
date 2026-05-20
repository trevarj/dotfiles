{
  self,
  pkgs,
  lib,
  ...
}: let
  localPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
  dotfilesRoot = ../assets/dotfiles;

  # Home Manager can either point directly at files or generate new files.  For
  # configs that mention Guix or Flatpak paths, generate a NixOS-specific view
  # while leaving the original dotfiles untouched.
  niriConfig =
    builtins.replaceStrings
    [
      ''spawn-sh-at-startup "flatpak ps --columns=application 2>/dev/null | grep -qx org.telegram.desktop || flatpak --user run org.telegram.desktop"''
      ''spawn-sh-at-startup "flatpak ps --columns=application 2>/dev/null | grep -qx com.brave.Browser || flatpak --user run com.brave.Browser"''
      ''spawn-sh-at-startup "swaybg -o '*' -i ~/Pictures/Wallpapers/a_rocky_shore_with_waves_crashing.jpg -m fill"''
      ''Mod+B hotkey-overlay-title="Launch a Browser: Brave" { spawn-sh "flatpak --user run com.brave.Browser"; }''
    ]
    [
      ''spawn-at-startup "telegram-desktop"''
      ''spawn-at-startup "brave"''
      ''spawn-sh-at-startup "${pkgs.swaybg}/bin/swaybg -o '*' -i /home/trev/Pictures/Wallpapers/a_rocky_shore_with_waves_crashing.jpg -m fill"''
      ''Mod+B hotkey-overlay-title="Launch a Browser: Brave" { spawn "brave"; }''
    ]
    (builtins.readFile (dotfilesRoot + "/niri/.config/niri/config.kdl"));

  topbarConfig =
    builtins.replaceStrings
    [
      "/run/current-system/profile/bin/loginctl"
      "/home/trev/Workspace/dotfiles/gnome-topbar/.config/gnome-topbar/scripts/crypto.sh"
    ]
    [
      "${pkgs.systemd}/bin/loginctl"
      "/home/trev/.config/gnome-topbar/scripts/crypto.sh"
    ]
    (builtins.readFile (dotfilesRoot + "/gnome-topbar/.config/gnome-topbar/config.toml"));
in {
  home.username = "trev";
  home.homeDirectory = "/home/trev";

  home.packages = with pkgs; [
    adwaita-icon-theme
    aspell
    aspellDicts.en
    aspellDicts.ru
    bat
    brave
    btop
    curl
    ddcutil
    direnv
    distrobox
    emacs-pgtk
    eza
    fd
    fzf
    gh
    git
    glib.bin
    gnupg
    hicolor-icon-theme
    imv
    jq
    kitty
    mpv
    msmtp
    nautilus
    fastfetch
    netcat-openbsd
    ollama
    papirus-icon-theme
    pinentry-tty
    ripgrep
    stow
    telegram-desktop
    tor
    torsocks
    unzip
    wireguard-tools
    xdg-utils
    yt-dlp
    zsh
    zsh-autosuggestions
    zsh-completions
    zsh-fzf-tab
    zsh-syntax-highlighting
    localPkgs.byedpi
    localPkgs.codex
    localPkgs.gnome-topbar
    localPkgs.nym-vpn
    localPkgs.opencode
  ];

  fonts.fontconfig.enable = true;

  home.file = {
    ".zsh_prompt.zsh-theme".source = dotfilesRoot + "/zsh/.zsh_prompt.zsh-theme";
    ".zsh_eza.zsh".source = dotfilesRoot + "/zsh/.zsh_eza.zsh";
    ".Xresources".source = dotfilesRoot + "/X/.Xresources";
    ".ssh/config".source = dotfilesRoot + "/ssh/.ssh/config";

    # Only the small custom font subset used by Kitty/topbar is vendored here;
    # Noto, emoji, Terminus, and other broad fonts come from Nixpkgs.
    ".local/share/fonts/IosevkaJbm/IosevkaJbm/TTF".source = dotfilesRoot + "/fonts/.local/share/fonts/IosevkaJbm/IosevkaJbm/TTF";
    ".local/share/fonts/NerdFonts".source = dotfilesRoot + "/fonts/.local/share/fonts/NerdFonts";
    ".local/share/fonts/cryptofont.ttf".source = dotfilesRoot + "/fonts/.local/share/fonts/cryptofont.ttf";

    "Pictures/Wallpapers/a_rocky_shore_with_waves_crashing.jpg".source = dotfilesRoot + "/wallpapers/Pictures/Wallpapers/a_rocky_shore_with_waves_crashing.jpg";
    "Pictures/Wallpapers/wallhaven-95kx6d.jpg".source = dotfilesRoot + "/wallpapers/Pictures/Wallpapers/wallhaven-95kx6d.jpg";
  };

  xdg.configFile = {
    "fontconfig/fonts.conf".source = dotfilesRoot + "/fonts/.config/fontconfig/fonts.conf";
    "fontconfig/conf.d/01-Emoji.conf".source = dotfilesRoot + "/fonts/.config/fontconfig/conf.d/01-Emoji.conf";
    "fontconfig/conf.d/02-NerdFonts.conf".source = dotfilesRoot + "/fonts/.config/fontconfig/conf.d/02-NerdFonts.conf";
    "niri/config.kdl".text = niriConfig;
    "fuzzel/fuzzel.ini".source = dotfilesRoot + "/fuzzel/.config/fuzzel/fuzzel.ini";
    "kitty/kitty.conf".source = dotfilesRoot + "/kitty/.config/kitty/kitty.conf";
    "hypr/hypridle.conf".source = dotfilesRoot + "/hypr/.config/hypr/hypridle.conf";
    "hypr/hyprlock.conf".source = dotfilesRoot + "/hypr/.config/hypr/hyprlock.conf";
    "hypr/hyprpaper.conf".source = dotfilesRoot + "/hypr/.config/hypr/hyprpaper.conf";
    "gnome-topbar/config.toml".text = topbarConfig;
    "gnome-topbar/scripts/crypto.sh" = {
      source = dotfilesRoot + "/gnome-topbar/.config/gnome-topbar/scripts/crypto.sh";
      executable = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    VISUAL = "emacs";
    LANGUAGE = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    BAT_THEME = "Nord";
    GOPATH = "$HOME/Workspace";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gpg = {
    enable = true;
    settings = {
      # Loopback lets terminal/editor tools ask for the passphrase themselves
      # when needed, matching the old Guix gpg.conf.
      pinentry-mode = "loopback";
      keyserver = "hkps://keys.openpgp.org";
      default-key = "A6C20D0C2AD838F949070EA3A52D68794EBED758";
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 43200;
    maxCacheTtl = 43200;
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignorePatterns = ["ls" "cd" "pwd" "exit" "sudo poweroff" "sudo reboot"];
    };
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

        setopt inc_append_history share_history
        setopt hist_ignore_all_dups
        setopt hist_ignore_space
        setopt autocd

        export GPG_TTY="$(tty)"
        export FZF_DEFAULT_OPTS='--color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'
        export PATH="$PATH:$HOME/.local/bin"

        [ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"
        [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      '')
      ''
        bindkey -e
        bindkey '^ ' autosuggest-accept

        alias sudo='sudo '
        alias open='xdg-open'
        alias tb='nc termbin.com 9999'
        alias et='emacs -nw'
        alias clear='printf "\033c"'

        source "$HOME/.zsh_eza.zsh"
        source "$HOME/.zsh_prompt.zsh-theme"

        zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
        zstyle ':fzf-tab:*' use-fzf-default-opts yes

        niri-session() {
          export XDG_CURRENT_DESKTOP="niri"
          export XDG_SESSION_TYPE="wayland"
          export XDG_SESSION_DESKTOP="niri"
          export GDK_BACKEND="wayland"
          export QT_QPA_PLATFORM="wayland"
          export SDL_VIDEODRIVER="wayland"
          export CLUTTER_BACKEND="wayland"
          export MOZ_ENABLE_WAYLAND=1

          exec niri --session
        }
      ''
    ];
    plugins = [
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
          sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
        };
      }
      {
        name = "fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
    ];
  };

  services.udiskie.enable = true;

  # This is the Home Manager equivalent of system.stateVersion.
  home.stateVersion = "26.05";
}
