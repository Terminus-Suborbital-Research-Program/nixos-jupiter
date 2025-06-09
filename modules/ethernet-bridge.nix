{ lib, config, pkgs, ... }:

let cfg = config.services.router;
in {
  options.services.router = {
    enable =
      lib.mkEnableOption "Enable simple router/NAT between Wi-Fi and Ethernet";

    wifiInterface = lib.mkOption {
      type = lib.types.str;
      default = "wlan0";
      description = "Upstream (internet-connected) wireless interface";
    };

    lanInterface = lib.mkOption {
      type = lib.types.str;
      default = "end0";
      description = "Downstream LAN Ethernet interface";
    };

    lanAddress = lib.mkOption {
      type = lib.types.str;
      default = "192.168.4.1";
      description = "Static IPv4 address for the LAN interface";
    };

    lanPrefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Subnet mask length for the LAN network";
    };

    dhcpRangeStart = lib.mkOption {
      type = lib.types.str;
      default = "192.168.4.10";
      description = "First address in the DHCP pool";
    };

    dhcpRangeEnd = lib.mkOption {
      type = lib.types.str;
      default = "192.168.4.100";
      description = "Last address in the DHCP pool";
    };

    dnsServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1.1.1.1" "8.8.8.8" ];
      description = "DNS servers handed out via DHCP";
    };
  };

  config = lib.mkIf cfg.enable {
    # Bring up wlan0 via DHCP
    networking.interfaces.${cfg.wifiInterface}.useDHCP = true;

    # Static IP on LAN port
    networking.interfaces.${cfg.lanInterface}.ipv4.addresses = [{
      address = cfg.lanAddress;
      prefixLength = cfg.lanPrefixLength;
    }];

    # Enable IPv4 forwarding
    boot.kernel.sysctl."net.ipv4.ip_forward" = true;

    # NAT/Masquerade (external = wifi, internal = lan)
    networking.nat.enable = true;
    networking.nat.externalInterface = cfg.wifiInterface;
    networking.nat.internalInterfaces =
      [ cfg.lanInterface ]; # :contentReference[oaicite:0]{index=0}

    # DHCP server on LAN via systemd-networkd
    systemd.network.enable = true;
    systemd.network.networks."10-${cfg.lanInterface}" = {
      matchConfig = { Name = cfg.lanInterface; };
      networkConfig = {
        Address = "${cfg.lanAddress}/${cfg.lanPrefixLength}";
        DHCPServer = "yes";
      };
      dhcpServerConfig = {
        # dhcp-range: start end
        Range = "${cfg.dhcpRangeStart} ${cfg.dhcpRangeEnd}";
        # space-separated DNS servers
        DNS = lib.concatStringsSep " " cfg.dnsServers;
      };
    }; # :contentReference[oaicite:1]{index=1}

    # Basic firewall (allows established + related by default)
    networking.firewall.enable = true;
  };
}
