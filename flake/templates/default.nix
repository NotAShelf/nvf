{
  flake.templates = {
    standalone = {
      path = ./standalone;
      description = "Standalone flake template for nvf";
      welcomeText = ''
        Template flake.nix has been created in flake.nix!

        Note that this is a very basic example to bootstrap nvf for you. Please edit your
        configuration as described in the nvf manual before using this template. The
        configured packages will be ran with 'nix run .' or 'nix run .#neovimConfigured'

        Happy editing!
      '';
    };
  };
}
