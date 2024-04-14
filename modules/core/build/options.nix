{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) path int package bool str listOf attrsOf;
  inherit (lib.nvim.types) pluginsOpt extraPluginType;
in {
  options.vim = {
    package = mkOption {
      type = package;
      default = pkgs.neovim-unwrapped;
      description = ''
        The neovim package to use.

        You will need to use an unwrapped package for this option to work as intended.
      '';
    };

    debugMode = {
      enable = mkEnableOption "debug mode";
      level = mkOption {
        type = int;
        default = 20;
        description = "Set the debug level";
      };

      logFile = mkOption {
        type = path;
        default = "/tmp/nvim.log";
        description = "Set the log file";
      };
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
        }'';
    };

    luaPackages = mkOption {
      type = listOf str;
      default = [];
      description = ''
        List of lua packages to install.
      '';
    };
  };
}
