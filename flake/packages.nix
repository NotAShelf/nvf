{inputs, ...}: {
  # imports = [
  #   inputs.flake-parts.flakeModules.easyOverlay
  # ];

  perSystem = {
    system,
    pkgs,
    config,
    ...
  }: let
    # inherit (import ../extra.nix inputs) neovimConfiguration mainConfig;

    # tidalConfig = {
    #   config.vim.tidal.enable = true;
    # };

    # buildPkg = pkgs: modules:
    #   (neovimConfiguration {
    #     inherit pkgs modules;
    #   })
    #   .neovim;

    # nixConfig = mainConfig false;
    # maximalConfig = mainConfig true;
  in {
    # overlayAttrs =
    #   {
    #     inherit neovimConfiguration;
    #     neovim-nix = config.packages.nix;
    #     neovim-maximal = config.packages.maximal;
    #   }
    #   // (
    #     if !(builtins.elem system ["aarch64-darwin" "x86_64-darwin"])
    #     then {neovim-tidal = config.packages.tidal;}
    #     else {}
    #   );

    packages = let
      docs = import ../docs {
        inherit pkgs;
        nmdSrc = inputs.nmd;
      };
    in
      {
        # Documentation
        docs = docs.manual.html;
        docs-html = docs.manual.html;
        docs-manpages = docs.manPages;
        docs-json = docs.options.json;

        # nvim configs
        # nix = buildPkg pkgs [nixConfig];
        # maximal = buildPkg pkgs [maximalConfig];
        nix = config.legacyPackages.neovim-nix;
        maximal = config.legacyPackages.neovim-maximal;
      }
      // (
        if !(builtins.elem system ["aarch64-darwin" "x86_64-darwin"])
        # then {tidal = buildPkg pkgs [tidalConfig];}
        then {tidal = config.legacyPackages.neovim-tidal;}
        else {}
      );
  };
}
