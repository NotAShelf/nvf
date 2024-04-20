{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption literalExpression;
  inherit (lib.types) package bool str listOf attrsOf;
  inherit (lib.nvim.types) pluginsOpt extraPluginType;
in {
  options.vim = {
    package = mkOption {
      type = package;
      default = pkgs.neovim-unwrapped;
      description = ''
        The neovim package to use.

        ::: {.warning}
        You will need to use an unwrapped package for this
        option to work as intended.
        :::
      '';
    };

    viAlias = mkOption {
      type = bool;
      default = true;
      description = "Enable the `vi` alias for `nvim`";
    };

    vimAlias = mkOption {
      type = bool;
      default = true;
      description = "Enable the `vim` alias for `nvim`";
    };

    startPlugins = pluginsOpt {
      default = ["plenary-nvim"];
      example = literalExpression ''
        [pkgs.vimPlugins.telescope-nvim]
      '';

      description = ''
        List of plugins to load on startup. This is used
        internally to add plugins to Neovim's runtime.

        To add additional plugins to your configuration, consider
        using the [{option}`vim.extraPlugins`](#opt-vim.optPlugins)
        option.
      '';
    };

    optPlugins = pluginsOpt {
      default = [];
      example = literalExpression ''
        [pkgs.vimPlugins.vim-ghost]
      '';
      description = ''
        List of plugins to optionally load on startup.

        This option has the same type definition as {option}`vim.startPlugins`
        and plugins in this list are appended to {option}`vim.startPlugins` by
        the wrapper during the build process.

        To avoid overriding packages and dependencies provided by startPlugins, you
        are recommended to use this option or {option}`vim.extraPlugins` option.
      '';
    };

    extraPlugins = mkOption {
      type = attrsOf extraPluginType;
      default = {};
      description = ''
        A list of plugins and their configurations that will be
        set up after builtin plugins.

        This option takes a special type that allows you to order
        your custom plugins using neovim-flake's modified DAG
        library.
      '';

      example = literalExpression ''
        with pkgs.vimPlugins; {
          aerial = {
            package = aerial-nvim;
            setup = "require('aerial').setup {}";
          };

          harpoon = {
            package = harpoon;
            setup = "require('harpoon').setup {}";
            after = ["aerial"]; # place harpoon configuration after aerial
          };
        }
      '';
    };

    luaPackages = mkOption {
      type = listOf str;
      default = [];
      example = literalExpression ''["magick" "serpent"]'';
      description = ''
        List of lua packages to install.
      '';
    };
  };
}
