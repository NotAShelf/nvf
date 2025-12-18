#### Prerequisites {#sec-flakes-prerequisites}

To install **nvf** with flakes, you must make sure the following requirements
are met.

1. Nix 2.4 or later must be installed. You may use `nix-shell` to get a later
   version of Nix from nixpkgs.
2. Flake-related experimental features must be enabled. Namely, you need
   `nix-command` and `flakes`. Some Nix vendors enable those by default, please
   consult their documentation if you are not using mainstream Nix.
   - When using NixOS, add the following to your `configuration.nix` and rebuild
     your system.

     ```nix
     nix.settings.experimental-features = "nix-command flakes";
     ```

   - If you are not using NixOS, add the following to `nix.conf` (located at
     `~/.config/nix/` or `/etc/nix/nix.conf`).

     ```bash
     experimental-features = nix-command flakes
     ```

   - You may need to restart the Nix daemon with, for example,
     `sudo systemctl restart nix-daemon.service`.

   - Alternatively, you can enable flakes on a per-command basis with the
     following additional flags to `nix` and `home-manager`:

     ```sh
     # Temporarily enables "nix-command" and "flakes" experimental features.
     $ nix --extra-experimental-features "nix-command flakes" <sub-commands>
     ```
