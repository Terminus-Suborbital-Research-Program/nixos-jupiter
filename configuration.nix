{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.11"; # Pinned, DON"T CHANGE

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # the user account on the machine
  users.users.terminus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPassword =
      "$6$/y/JpKnBdDNKy4TT$AwhlCR6pIDBvvzdk8ZIKQFUQ/qp4o5lGJJq3kLQtnFHfuW6eJbbz7Pd/MxDOV8Ie0/0moYgCxTln0a9UA0Edz.";
  };

  networking.wireless = {
    enable = true;
    networks."Staff5".psk = "Where is the coffee?";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # I use neovim as my text editor, replace with whatever you like
  environment.systemPackages = with pkgs; [ neovim wget ];

  # allows the use of flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # this allows you to run `nixos-rebuild --target-host admin@this-machine` from
  # a different host. not used in this tutorial, but handy later.
  nix.settings.trusted-users = [ "terminus" ];

  environment.variables = { EDITOR = "neovim"; };
}
