{
  description = "AMALTHEA NixOS Flake";

  inputs = {
    # Pinning nixpkgs here - they dropped support for the
    # old pi hardware config in this version.
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    guard.url = "github:Terminus-Suborbital-Research-Program/GUARD";
    jupiter.url = "github:Terminus-Suborbital-Research-Program/AMALTHEA";
    probe-rs-rules.url = "github:jneem/probe-rs-rules";
  };

  outputs = { nixpkgs, nixos-hardware, guard, jupiter, probe-rs-rules, ... }: {
    nixosConfigurations."dev-pi" = let system = "aarch64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix
        ./modules/programs.nix
        ./modules/user.nix
        ./modules/wireless.nix
        ./modules/probe-rs.nix
        probe-rs-rules.nixosModules.${system}.default
      ];
    };

    nixosConfigurations."jupiter" = let
      system = "aarch64-linux";
      jupiter-pkg = jupiter.packages.${system}.jupiter-fsw;
      radiaread = guard.packages.${system}.radiaread;
      pkgs = import nixpkgs { inherit system; };
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix
        ./modules/programs.nix
        ./modules/user.nix
        ./modules/wireless.nix
        ./modules/lsm6dt.nix
        {
          environment.systemPackages = [ radiaread jupiter-pkg ];

          # ensure the data dir exists at boot
          systemd.tmpfiles.rules = [
            # format: TYPE PATH MODE OWNER GROUP AGE ARGUMENT
            "d /home/terminus/rad_data 0755 terminus terminus - -"
          ];

          systemd.services.radiaread = {
            description = "Terminus Radiacode Data Reader";
            # make sure networking (and tmpfiles) is ready first
            after = [ "systemd-tmpfiles-setup.service" ];
            path = [ radiaread ];

            # drop into the right directory and run the binary
            serviceConfig = {
              WorkingDirectory = "/home/terminus/rad_data";
              ExecStart = "${radiaread}/bin/radiaread /home/terminus/rad_data";
              Restart = "always";
              RestartSec = "20s";
              Group = "dialout";
            };

            # enable the service at boot
            wantedBy = [ "multi-user.target" ];
          };

          systemd.services.jupiter = {
            description = "JUPITER Flight software";
            after = [ "systemd-tmpfiles-setup.service" ];
            path = [ jupiter-pkg pkgs.libgpiod pkgs.ffmpeg ];

            serviceConfig = {
              WorkingDirectory = "/home/terminus/";
              ExecStart =
                "${jupiter.packages.${system}.jupiter-fsw}/bin/jupiter-fsw";
              Restart = "always";
              RestartSec = "2s";
              User = "terminus";
            };
          };
        }
      ];

    };

    nixosConfigurations."nuc" = let system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./nuc-config.nix
        ./modules/programs.nix
        ./modules/user.nix
        { environment.systemPackages = [ guard.packages.${system}.radiaread ]; }
      ];
    };
  };
}
