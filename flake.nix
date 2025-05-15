{
	description = "AMALTHEA NixOS Flake";

	inputs = {
		# Pinning nixpkgs here - they dropped support for the
		# old pi hardware config in this version.
		nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";
		nixos-hardware.url = "github:NixOs/nixos-hardware/master";
	};

	outputs = { self, nixpkgs, nixos-hardware, ... }@inputs: rec {
		nixosConfigurations."jupiter" = nixpkgs.lib.nixosSystem {
			system = "aarch64-linux";
			modules = [
                nixos-hardware.nixosModules.raspberrypi4
				./configuration.nix
			];
		};
	};
}