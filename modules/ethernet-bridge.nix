{ lib, config, pkgs, ... }:

{
  #### Use systemd-networkd and wpa_supplicant for networking (no NetworkManager) ####

  networking.useNetworkd = true;
  # Enable systemd-networkd for interface management (instead of NetworkManager).
  networking.networkmanager.enable = false;
  # Disable NetworkManager to avoid conflicts, since we use wpa_supplicant + networkd.

  networking.wireless.enable = true;
  # Enable wpa_supplicant for WiFi. 
  # (Ensure to configure your WiFi network in networking.wireless.networks or via wpa_supplicant config.)

  #### Configure WiFi interface (uplink) ####

  # Define networkd settings for the WiFi interface (e.g., wlan0) which is the uplink to the internet.
  systemd.network.networks."10-wlan0" = {
    matchConfig.Name = "wlan0"; # Match the WiFi interface by name.
    networkConfig.DHCP =
      "ipv4"; # Obtain IP configuration via DHCP from the WiFi network.
    networkConfig.IPMasquerade =
      true; # Masquerade (NAT) outgoing traffic on wlan0 for downstream clients:contentReference[oaicite:2]{index=2}.
    # IPMasquerade will SNAT traffic leaving wlan0, making it appear as if it originates from this host, 
    # which enables internet access for the LAN clients. This implicitly enables IPv4 forwarding as well:contentReference[oaicite:3]{index=3}.
    #
    # (No static addresses on wlan0; it’s a DHCP client on the upstream WiFi. 
    # IPMasquerade is a simple one-line NAT setup by networkd, avoiding manual iptables rules:contentReference[oaicite:4]{index=4}.)
  };

  #### Configure Ethernet interface (downlink to LAN) ####

  # Define networkd settings for the Ethernet interface which serves the downstream device.
  systemd.network.networks."20-end0" = {
    matchConfig.Name = "end0"; # Match the Ethernet interface by name.
    networkConfig.Address =
      "10.0.0.1/24"; # Assign a static IP for the LAN (e.g., 10.0.0.1/24):contentReference[oaicite:5]{index=5}.
    networkConfig.DHCPServer =
      true; # Enable a simple DHCP server on this interface (served range within 10.0.0.0/24).
    # The DHCP server will hand out addresses to connected clients. By default, systemd-networkd’s DHCP server 
    # will use 10.0.0.1 as gateway and start the pool at .2 up to .254 (covering the /24):contentReference[oaicite:6]{index=6}.
    # It also propagates DNS servers from the uplink automatically by default:contentReference[oaicite:7]{index=7}, 
    # so downstream clients receive the same DNS as the WiFi interface (or those in /etc/resolv.conf).
    #
    # No separate dnsmasq/kea service is needed – this built-in DHCP is fully declarative and minimal.
  };

  #### System-wide IP forwarding (if not already enabled by networkd) ####

  # Ensure IP forwarding is enabled (allows the host to route packets between interfaces).
  # (IP forwarding is generally enabled automatically when IPMasquerade or DHCPServer is used in networkd, 
  # but we set it explicitly for completeness.)
  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault true;

  #### Minimal firewall rules for NAT and LAN ####

  networking.firewall.enable = true;
  # Keep the firewall enabled for safety (using iptables by default).

  networking.firewall.trustedInterfaces = [ "end0" ];
  # Trust the Ethernet LAN interface: accept all traffic from the downstream side:contentReference[oaicite:8]{index=8}.
  # This allows DHCP and any LAN-originating connections through without complex rules.
  # (The WiFi interface remains subject to the default firewall, protecting the host from external traffic.)

  # (The masquerade on wlan0 set above adds the necessary NAT rule for outbound traffic, 
  # so no manual iptables rules are needed. The combination of IPMasquerade and a trusted LAN interface 
  # achieves a simple internet sharing setup with minimal firewall/NAT complexity:contentReference[oaicite:9]{index=9}.)
}
