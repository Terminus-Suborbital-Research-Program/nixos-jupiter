# JUPITER Operating System Configuation
This is the operating system configuration `nixos` flake for JUPITER. It will boot up JUPITER into a headless environment - the only offline item will be the ZeroTier VPN, that must be provisioned by Lucas Thelen in order to run.
# Instructions
To reload/rebuild the configuration natively on JUPITER, from this directory run `sudo nixos-rebuild switch --flake .#jupiter`.
