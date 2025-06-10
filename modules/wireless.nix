{ config, pkgs, ... }: {
  networking.wireless = {
    enable = true;
    networks."Staff5".pskRaw =
      "66fe08674eda745336a1ac1dddf2e7fef7d1374a6c73184194a05332e0648ff1";
    networks."Pixel_8877".pskRaw =
      "$6$TgralEdk2gvg529U$kTVLKVujUYZs2XPcvleKOj121QngbJmCx53dV1YJAaKMlrL92TzKCose2LzWuqYuXhqSdyVEq72EIUy5XPG6a0";
  };

  # Disable bluetooth
  hardware.bluetooth.enable = false;
}
