{ config, pkgs, ... }:

{
  imports = [ ];

  system.stateVersion = "24.11"; # Pinned, DON"T CHANGE

  boot.kernelParams =
    [ "console=tty1" "8250.nr_uarts=1" "console=serial0,115200n8" ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Group for GPIO access
  users.groups.gpio = { };

  # Set udev rules for GPIO access
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="gpio", MODE="0660"
  '';

  # the user account on the machine
  users.users.terminus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "gpio" "i2c" ];
    hashedPassword =
      "$6$/y/JpKnBdDNKy4TT$AwhlCR6pIDBvvzdk8ZIKQFUQ/qp4o5lGJJq3kLQtnFHfuW6eJbbz7Pd/MxDOV8Ie0/0moYgCxTln0a9UA0Edz.";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/QIvKf8yNyDwfBHuyoL9lrhnewB9FO+33SnxyoD+AJ lucas@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXPxcaJrD7Lu2P1/CxCwoKySNrszKuXgJteVZFo9vk3 supergoodname77@cachyos-x8664"
    ];
  };

  networking.hostName = "jupiter";

  networking.wireless = {
    enable = true;
    networks."Staff5".pskRaw =
      "66fe08674eda745336a1ac1dddf2e7fef7d1374a6c73184194a05332e0648ff1";
  };

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
