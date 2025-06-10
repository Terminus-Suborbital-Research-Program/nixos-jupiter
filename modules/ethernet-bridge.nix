{ lib, config, pkgs, ... }:
let
  # Original values
  ethPiAddress = "192.168.10.1"; # Pi’s address on eth0
  ethPrefix = 24;

  # Compute “192.168.10” from “192.168.10.1”
  parts = builtins.splitString "." ethPiAddress; # [ "192" "168" "10" "1" ]
  ethSubnetBase =
    builtins.concatStringsSep "." (builtins.take 3 parts); # "192.168.10
in {
  #### Use systemd-networkd and wpa_supplicant for networking (no NetworkManager) ####

  networking.networkmanager.enable = true;
  # Disable NetworkManager to avoid conflicts, since we use wpa_supplicant + networkd.

  networking.wireless.enable = true;
  # Enable wpa_supplicant for WiFi. 
  services.dnsmasq.enable = true;
  services.dnsmasq.interfaces = [ "end0" ];
  services.dnsmasq.extraConfig = ''
    # give clients .10–.100, 12-hour leases
    dhcp-range=${ethSubnetBase}.10,${ethSubnetBase}.100,255.255.255.0,12h
    dhcp-option=option:router,${ethPiAddress}
    dhcp-option=option:dns-server,8.8.8.8,8.8.4.4
  ''; # (Ensure to configure your WiFi network in networking.wireless.networks or via wpa_supplicant config.)

  networking.interfaces.end0.ipv4 = {
    dhcp = false;
    addresses = [{
      address = ethPiAddress;
      prefixLength = ethPrefix;
    }];
  };

  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };
  #### Configure WiFi interface (uplink) ####

  networking.firewall.enable = true;

  networking.firewall.trustedInterfaces = [ "end0" ];
}
