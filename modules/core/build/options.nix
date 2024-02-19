{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption literalExpression;
  inherit (lib.types) package bool oneOf listOf lines str attrsOf attrs;
  inherit (lib.nvim.types) dagOf pluginsOpt extraPluginType;
in {
  options.vim = {
    package = mkOption {
      type = package;
      default = pkgs.neovim-unwrapped;
      description = ''
        The neovim package to use. You will need to use an unwrapped package for this option to work as intended.
      '';
    };

    viAlias = mkOption {
      description = "Enable vi alias";
      type = bool;
      default = true;
    };

    vimAlias = mkOption {
      description = "Enable vim alias";
      type = bool;
      default = true;
    };

    configRC = mkOption {
      description = "vimrc contents";
      type = oneOf [(dagOf lines) str];
      default = {};
    };

    luaConfigRC = mkOption {
      description = "vim lua config";
      type = oneOf [(dagOf lines) str];
      default = {};
    };

    builtConfigRC = mkOption {
      internal = true;
      type = lines;
      description = "The built config for neovim after resolving the DAG";
    };

    startPlugins = pluginsOpt {
      default = [];
      description = "List of plugins to startup.";
    };

    optPlugins = pluginsOpt {
      default = [];
      description = "List of plugins to optionally load";
    };

    extraPlugins = mkOption {
      type = attrsOf extraPluginType;
      default = {};
      description = ''
        List of plugins and related config.
        Note that these are setup after builtin plugins.
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
            after = ["aerial"];
          };
        }
      '';
    };

    luaPackages = mkOption {
      type = listOf str;
      default = [];
      description = ''
        List of lua packages to install.
      '';
    };

    globals = mkOption {
      default = {};
      description = "Set containing global variable values";
      type = attrs;
    };
  };
}
