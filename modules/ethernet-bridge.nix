{ lib, config, pkgs, ... }:

{
  #### Use systemd-networkd and wpa_supplicant for networking (no NetworkManager) ####

  networking.networkmanager.enable = true;
  # Disable NetworkManager to avoid conflicts, since we use wpa_supplicant + networkd.

  networking.wireless.enable = true;
  # Enable wpa_supplicant for WiFi. 
  # (Ensure to configure your WiFi network in networking.wireless.networks or via wpa_supplicant config.)

  #### Configure WiFi interface (uplink) ####

  # Define networkd settings for the WiFi interface (e.g., wlan0) which is the uplink to the internet.

  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault true;

  networking.firewall.enable = true;

  networking.firewall.trustedInterfaces = [ "end0" ];
}
