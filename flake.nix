{
  description = "AMALTHEA NixOS Flake";

  inputs = {
    # Pinning nixpkgs here - they dropped support for the
    # old pi hardware config in this version.
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    guard.url = "github:Terminus-Suborbital-Research-Program/GUARD";
    infratracker.url =
      "github:Terminus-Suborbital-Research-Program/COTS-Star-Tracker-Amalthea";
  };

  outputs =
    { self, nixpkgs, nixos-hardware, guard, infratracker, ... }@inputs: rec {
      nixosConfigurations."jupiter" = let system = "aarch64-linux";
      in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./configuration.nix
          ./modules/programs.nix
          ./modules/user.nix
          ./modules/wireless.nix
          {
            environment.systemPackages = [
              guard.packages.${system}.radiaread
              infratracker.packages.${system}.infratracker
            ];

            # ensure the data dir exists at boot
            systemd.tmpfiles.rules = [
              # format: TYPE PATH MODE OWNER GROUP AGE ARGUMENT
              "d /home/terminus/rad_data 0755 terminus terminus - -"
              "d /home/terminus/infratracker_data 0755 terminus terminus - -"
            ];

            systemd.services.radiaread = {
              description = "Terminus Radiacode Data Reader";
              # make sure networking (and tmpfiles) is ready first
              after = [ "systemd-tmpfiles-setup.service" ];

              # drop into the right directory and run the binary
              serviceConfig = {
                WorkingDirectory = "/home/terminus/rad_data";
                ExecStart = "${
                    guard.packages.${system}.radiaread
                  }/bin/radiaread /home/terminus/rad_data";
                Restart = "always";
                RestartSec = "5s";
                Group = "dialout";
              };

              # enable the service at boot
              wantedBy = [ "multi-user.target" ];
            };

            systemd.services.infratracker = {
              description = "Terminus Infratracker Daemon";
              after = [ "systemd-tmpfiles-setup.service" ];

              serviceConfig = {
                WorkingDirectory = "/home/terminus/infratracker_data";
                ExecStart = "${
                    infratracker.packages.${system}.infratracker
                  }/bin/infratracker /home/terminus/infratracker_data";
                Restart = "always";
                RestartSec = "5s";
                Group = "dialout";
              };

              wantedBy = [ "multi-user.target" ];
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
          {
            environment.systemPackages = [ guard.packages.${system}.radiaread ];
          }
        ];
      };
    };
}
