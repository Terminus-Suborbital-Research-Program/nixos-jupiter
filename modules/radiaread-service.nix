{ config, guard, ... }:

let
  system = config.system;
  RR = guard.packages.${system}.radiaread;
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
      WorkingDirectory = "/home/terminus/rad_data";
      ExecStart = "${RR}/bin/radiaread";
      # if you need args, e.g. --output /home/terminus/rad_data, add them here:
      # ExecStart = "${RR}/bin/radiaread --output-dir /home/terminus/rad_data";
      Restart = "always";
      RestartSec = "5s";
      User = "terminus";
      Group = "terminus";
    };

    # enable the service at boot
    wantedBy = [ "multi-user.target" ];
  };
}

