{ config, pkgs, ... }:

{
  imports = [ ./hardware/hardware-jupiter.nix ];

  system.stateVersion = "24.11"; # Pinned, DON"T CHANGE

  boot.kernelParams = [
    "console=tty1"
    "8250.nr_uarts=4"
    "console=serial0,115200n8"
    "dtoverlay=uart2"
  ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  nixpkgs.config.allowUnfree = true;

  hardware.deviceTree = {
    enable = true;
    overlays = [{
      name = "uart1-overlay";
      dtsText = builtins.readFile ./uart1-overlay.dts;
    }];
  };
  hardware.i2c.enable = true;

  hardware.raspberry-pi."4" = {
    i2c1.enable = true;
    bluetooth.enable = false;
  };

  # Group for GPIO access
  users.groups.gpio = { };
  users.groups.video = { };

  # Set udev rules for GPIO access
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="gpio", MODE="0660"

    # Allied Vision Alvium 1800 U-501m – raw USB node
    SUBSYSTEM=="usb", ATTR{idVendor}=="1ab2", ATTR{idProduct}=="0001", MODE="0660", GROUP="video", SYMLINK+="alvium-%k"

    # /etc/udev/rules.d/99-radiacode.rules
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="f123", MODE="0660", GROUP="dialout", SYMLINK+="radia_code"
  '';

  systemd.services.gpioDown = let

    script = pkgs.writeShellScript "gpio-down.sh" ''
      # assert the line and keep the process in the background
      gpioset -z GPIO12=inactive &
      sleep 2
      pkill -f gpioset
    '';
  in {
    description =
      "Pull GPIO-12 low for two seconds at boot to prevent ejection";

    path = with pkgs; [ libgpiod procps ]; # gpioset & pkill
    wantedBy = [ "multi-user.target" ];
    after = [ "basic.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = script; # <- a single, valid ExecStart=
      RemainAfterExit = true;
    };
  };

  networking.hostName = "jupiter";

  boot.postBootCommands = ''
    gpioset 'GPIO12=active' & sleep 1 && pkill gpioset
  '';

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8056c2e21cb25d85" ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # VSCode patch
  programs.nix-ld.enable = true;

  # allows the use of flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.trusted-users = [ "terminus" ];

  environment.variables = { EDITOR = "nvim"; };
}
