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

    gnome-topbar-src = {
      # This is a normal flake input, pinned in flake.lock like a Guix channel.
      # It intentionally does not depend on a local checkout, so fresh installs
      # can build the full system from this repository plus the lock file.
      url = "github:trevarj/gnome-topbar";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    disko,
    gnome-topbar-src,
  }: let
    system = "x86_64-linux";
    specialArgs = {
      inherit self disko;
    };
  in {
    nixosConfigurations.stinkpad = nixpkgs.lib.nixosSystem {
      inherit system;

      # specialArgs is how flakes pass shared values into every imported NixOS
      # module.  Think of it as explicit lexical context, not global state.
      inherit specialArgs;

      modules = [
        ./hosts/stinkpad
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit self;
          };
          home-manager.users.trev = import ./home/trev.nix;
        }
      ];
    };

    nixosConfigurations.trev-installer = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./modules/installer/iso.nix
      ];
    };

    # diskoConfigurations are consumed by the `disko` CLI.  diskDevice is
    # supplied by the installer script after the user explicitly selects a disk.
    diskoConfigurations.stinkpad = {
      diskDevice ? throw "Pass --argstr diskDevice /dev/...",
      ...
    }: import ./modules/disk/stinkpad.nix {inherit diskDevice;};

    packages.${system} = let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in import ./pkgs {inherit pkgs gnome-topbar-src;};

    devShells.${system} = let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in import ./shells {inherit pkgs;};
  };
}
