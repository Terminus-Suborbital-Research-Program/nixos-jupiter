{ config, jupiter, ... }:

let
  system = config.system;
  jupiter-fsw = jupiter.packages.${system}.jupiter-fsw;
in {
  # ensure the data dir exists at boot
  systemd.tmpfiles.rules = [
    # format: TYPE PATH MODE OWNER GROUP AGE ARGUMENT
    "d /home/terminus/rad_data 0755 terminus terminus - -"
  ];

  systemd.services.radiaread = {
    description = "Terminus Radiacode Data Reader";
    # make sure networking (and tmpfiles) is ready first
    after = [ "network-online.target" "systemd-tmpfiles-setup.service" ];
    wants = [ "network-online.target" ];

    # drop into the right directory and run the binary
    serviceConfig = {
      WorkingDirectory = "/home/terminus/";
      ExecStart = "${jupiter-fsw}/bin/jupiter-fsw";
      Restart = "always";
      RestartSec = "1s";
      User = "terminus";
      Group = "terminus";
    };

    # enable the service at boot
    wantedBy = [ "multi-user.target" ];
  };
}

