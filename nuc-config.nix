# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware/hardware-nuc.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # module
  boot.extraModulePackages = with config.boot.kernelPackages;
    [ rtl88xxau-aircrack ];

  networking.hostName = "nuc"; # Define your hostname.

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #  # Set your time zone.
  time.timeZone = "US/Chicaco";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    kea
    vim
    vscode
    kitty
    git
    neovim
    zerotierone
  ];

  programs.nix-ld.enable = true;

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

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8056c2e21cb25d85" ];
  };

  services.openssh = { enable = true; };

  system.stateVersion = "24.11"; # Did you read the comment?
}

