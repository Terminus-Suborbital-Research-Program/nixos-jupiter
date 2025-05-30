{
  description = "AMALTHEA NixOS Flake";

  inputs = {
    # Pinning nixpkgs here - they dropped support for the
    # old pi hardware config in this version.
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    guard.url = "github:Terminus-Suborbital-Research-Program/GUARD";
  };

  outputs = { self, nixpkgs, nixos-hardware, guard, ... }@inputs: rec {
    nixosConfigurations."jupiter" = let system = "aarch64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix
        ./modules/programs.nix
        ./modules/user.nix
        ./modules/wireless.nix
        {environment.systemPackages = [ guard.packages.${system}.radiaread ];}
      ];

    };

    nixosConfigurations."nuc" = let system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ 
      ./nuc-config.nix 
      ./modules/programs.nix 
      ./modules/user.nix
        {environment.systemPackages = [ guard.packages.${system}.radiaread ];}
	];
    };
  };
}
