{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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
  users.groups.gpio = {};
  users.groups.video = {};

  # Set udev rules for GPIO access
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="gpio", MODE="0660"

    # Allied Vision Alvium 1800 U-501m – raw USB node
    SUBSYSTEM=="usb", ATTR{idVendor}=="1ab2", ATTR{idProduct}=="0001", MODE="0660", GROUP="video", SYMLINK+="alvium-%k"
  '';

  # Task to pull GPIO low at start
  systemd.services.gpioDown = {
    description =
      "Pull down the GPIO line at startup to avoid unintentional ejections";

    serviceConfig = {
      Type = "oneshot";

      ExecStart = ''
        ${pkgs.bash}/bin/bash -c "gpioset 'GPIO12=active' & sleep 2 && pkill gpio"'';

      path = with pkgs; [ bash libgpiod ];

      wantedBy = [ "multi-user.target" ];
    };
  };

  # the user account on the machine
  users.users.terminus = {
    isNormalUser = true;
    extraGroups = [ 
        "wheel"
        "dialout"
        "gpio"
        "i2c"
        "uart"
        "video"
    ];
    hashedPassword =
      "$6$/y/JpKnBdDNKy4TT$AwhlCR6pIDBvvzdk8ZIKQFUQ/qp4o5lGJJq3kLQtnFHfuW6eJbbz7Pd/MxDOV8Ie0/0moYgCxTln0a9UA0Edz.";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/QIvKf8yNyDwfBHuyoL9lrhnewB9FO+33SnxyoD+AJ lucas@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXPxcaJrD7Lu2P1/CxCwoKySNrszKuXgJteVZFo9vk3 supergoodname77@cachyos-x8664"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCX4xbbfhNuS6F5cb1dwHMmi+0T5B+Tea8QVfiYP5Ncia5J+BiMFxEH9S49QY9kpln3FchKxhWerUeftbW2gGUkdICIdjyEjShNYXHsSQoqvxlhaSvxJ5NsDpsu+kR1PoSrHmWyUcea5Bqy6S3lLEb5EcOzNjhuquJCoDRgRZQHNaPDHz3i+92bIAWAosu+mMkEa5/SxIxAh/6z+P3loHshtYWdEsMupOlX5MxHfXOepFVN7KTX36Rrqao198TSc0oik9JIOMUlmTc/EaU4PvXHI5I3T43JXOpFTLrJWkUGpPbUOaNzz7yOYqr2hvClA9aOzJIXtYWTcagQqFI2+VsstvNA1ci6/0UVhtBxuH1vs5F5P8IM6fScs9WCu4TE2rEDThzfrHpCuLWFhsYV+5dxGXEm+RrJmroUpelnm67CrNWgqgQPqJq55MZi0hHoxOXiFd/FyLwmULhajIfRJjkm2S1zbXAHUQ2Wju6mV2YrMpNlkpURKRcNtJx4OqLa1wE= bigmeech@hephaestus"
    ];
  };

  networking.hostName = "jupiter";

  networking.wireless = {
    enable = true;
    networks."Staff5".pskRaw =
      "66fe08674eda745336a1ac1dddf2e7fef7d1374a6c73184194a05332e0648ff1";
  };

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

  environment.systemPackages = with pkgs; [
    htop
    usbutils
    lsof
    lazygit
    dtc
    picocom
    aravis
    libraspberrypi
    neovim
    ffmpeg
    direnv
    libgpiod
    wget
    kitty
    git
    htop
    v4l-utils
    neofetch
    i2c-tools
  ];

  # allows the use of flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # this allows you to run `nixos-rebuild --target-host admin@this-machine` from
  # a different host. not used in this tutorial, but handy later.
  nix.settings.trusted-users = [ "terminus" ];

  environment.variables = { EDITOR = "nvim"; };
}
