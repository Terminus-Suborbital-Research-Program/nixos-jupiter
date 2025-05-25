{ system, config, pkgs, ... }: {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };
  networking.interfaces."end0" = {
  # useDHCP = false;
  #  ipv4.addresses = [{
  #    "address" = "9.9.0.1";
  #    prefixLength = 24;
  #  }];
  };
  networking.firewall.extraCommands = ''
    INTERNET=wlp0s20u2
    LAN=eno1

    iptables -t nat -A POSTROUTING -o $LAN -j MASQUERADE
    iptables -A FORWARD -i $LAN -o $INTERNET -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i $INTERNET -o $LAN -j ACCEPT
  '';

  networking.firewall.allowedTCPPorts = [ 53 67 ];
  networking.firewall.allowedUDPPorts = [ 53 67 ];


  ## Run DHCP server on the downstream interface
  #services.kea.dhcp4 = {
  #  enable = true;
  #  settings = {
  #    interfaces-config = {
  #      interfaces = [
  #        "eno1"
  #      ];
  #    };
  #    lease-database = {
  #      name = "/var/lib/kea/dhcp4.leases";
  #      persist = true;
  #      type = "memfile";
  #    };
  #    rebind-timer = 2000;
  #    renew-timer = 1000;
  #    subnet4 = [
  #      {
  #        id = 1;
  #        pools = [{
  #          pool = "9.0.0.2 - 9.0.0.255";
  #        }];
  #        subnet = "9.0.0.1/24";
  #      }
  #    ];
  #    valid-lifetime = 4000;
  #    option-data = [{
  #      name = "routers";
  #      data = "9.0.0.1";
  #    }];
  #  };
  #};
}
