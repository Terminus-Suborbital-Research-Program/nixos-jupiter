{ pkgs, ... }: {
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
    uvcdynctrl
    mjpg-streamer
    wget
    kitty
    git
    btop
    v4l-utils
    neofetch
    i2c-tools
  ];
}
