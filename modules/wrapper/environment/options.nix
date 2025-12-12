{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.types) package bool str listOf attrsOf;
  inherit (lib.nvim.types) pluginsOpt extraPluginType;
in {
  options.vim = {
    package = mkOption {
      type = package;
      default = pkgs.neovim-unwrapped;
      defaultText = literalExpression "pkgs.neovim-unwrapped";
      description = ''
        The neovim package to use for the wrapper. This
        corresponds to the package that will be wrapped
        with your plugins and settings.

        ::: {.warning}
        You will need to use an unwrapped package for this
        option to work as intended. Using an already wrapped
        package here may yield undesirable results.
        :::
      '';
    };

    viAlias = mkOption {
      type = bool;
      default = true;
      example = false;
      description = "Enable the `vi` alias for `nvim`";
    };

    vimAlias = mkOption {
      type = bool;
      default = true;
      example = false;
      description = "Enable the `vim` alias for `nvim`";
    };

    startPlugins = pluginsOpt {
      default = ["plenary-nvim"];
      example = literalExpression "[pkgs.vimPlugins.telescope-nvim]";
      description = ''
        List of plugins to load on startup. This is used
        internally to add plugins to Neovim's runtime.

        To add additional plugins to your configuration, consider
        using the {option}`vim.extraPlugins`
        option.
      '';
    };

    optPlugins = pluginsOpt {
      default = [];
      example = literalExpression "[pkgs.vimPlugins.vim-ghost]";
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
        your custom plugins using nvf's modified DAG library.
      '';

      example = literalMD ''
        ```nix
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
        ```
      '';
    };

    extraPackages = mkOption {
      type = listOf package;
      default = [];
      example = ''[pkgs.fzf pkgs.ripgrep]'';
      description = ''
        List of additional packages to make available to the Neovim
        wrapper.
      '';
    };

    # This defaults to `true` in the wrapper
    # and since we pass this value to the wrapper
    # with an inherit, it should be `true` here as well
    withRuby =
      mkEnableOption ''
        Ruby support in the Neovim wrapper.
      ''
      // {
        default = true;
      };

    withNodeJs = mkEnableOption ''
      NodeJS support in the Neovim wrapper
    '';

    luaPackages = mkOption {
      type = listOf str;
      default = [];
      example = ''["magick" "serpent"]'';
      description = "List of Lua packages to install";
    };

    withPython3 = mkEnableOption ''
      Python3 support in the Neovim wrapper
    '';

    python3Packages = mkOption {
      type = listOf str;
      default = [];
      example = ''["pynvim"]'';
      description = "List of python packages to install";
    };

    pluginOverrides = mkOption {
      type = attrsOf package;
      default = {};
      example = literalExpression ''
        {
          lazydev-nvim = pkgs.fetchFromGitHub {
            owner = "folke";
            repo = "lazydev.nvim";
            rev = "";
            hash = "";
          };
        }
      '';
      description = "Attribute set of plugins to override default values";
    };
  };
}
