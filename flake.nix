{
  description = "Trev's NixOS and Home Manager configuration";

  inputs = {
    # A flake input is closest to a pinned Guix channel: it names an upstream
    # source, and flake.lock records the exact revision once `nix flake lock`
    # is run.  Unstable is intentional here because Niri and the Wayland stack
    # move quickly.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager is the NixOS analogue to Guix Home for user packages,
    # dotfiles, and per-user services.  Following nixpkgs keeps both on one
    # package universe.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko is the NixOS equivalent of making partitioning/formatting part of
    # the declarative install plan.  We use it only during installation.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix keeps private material encrypted in the repo and materializes it
    # only during activation on machines that have an allowed age identity.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gnome-topbar-src = {
      # Track upstream master, but keep the exact commit pinned in flake.lock.
      # Run `nix flake update gnome-topbar-src` to advance to current master.
      # This avoids relying on a local checkout while keeping builds repeatable.
      url = "github:trevarj/gnome-topbar/master";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    disko,
    sops-nix,
    gnome-topbar-src,
  }: let
    system = "x86_64-linux";
    specialArgs = {
      inherit self disko sops-nix;
    };
  in {
    nixosConfigurations.stinkpad = nixpkgs.lib.nixosSystem {
      inherit system;

      # specialArgs is how flakes pass shared values into every imported NixOS
      # module.  Think of it as explicit lexical context, not global state.
      inherit specialArgs;

      modules = [
        ./trev-nix/hosts/stinkpad
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            sops-nix.homeManagerModules.sops
          ];
          home-manager.extraSpecialArgs = {
            inherit self;
          };
          home-manager.users.trev = import ./trev-nix/home/trev.nix;
        }
      ];
    };

    nixosConfigurations.trev-installer = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./trev-nix/modules/installer/iso.nix
      ];
    };

    # diskoConfigurations are consumed by the `disko` CLI.  diskDevice is
    # supplied by the installer script after the user explicitly selects a disk.
    diskoConfigurations.stinkpad = {
      diskDevice ? throw "Pass --argstr diskDevice /dev/...",
      ...
    }: import ./trev-nix/modules/disk/stinkpad.nix {inherit diskDevice;};

    packages.${system} = let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in import ./trev-nix/pkgs {inherit pkgs gnome-topbar-src;};

    devShells.${system} = let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in import ./trev-nix/shells {inherit pkgs;};
  };
}
