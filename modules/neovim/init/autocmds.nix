{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.lists) filter;
  inherit (lib.strings) optionalString;
  inherit (lib.types) nullOr submodule listOf str bool;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter entryBetween;

  autocommandType = submodule {
    options = {
      enable =
        mkEnableOption ""
        // {
          default = true;
          description = "Whether to enable this autocommand.";
        };

      event = mkOption {
        type = nullOr (listOf str);
        default = null;
        example = ["BufRead" "BufWritePre"];
        description = "The event(s) that trigger the autocommand.";
      };

      pattern = mkOption {
        type = nullOr (listOf str);
        default = null;
        example = ["*.lua" "*.vim"];
        description = "The file pattern(s) that determine when the autocommand applies.";
      };

      callback = mkOption {
        type = nullOr luaInline;
        default = null;
        example = literalExpression ''
          lib.generators.mkLuaInline '''
            function()
                print("Saving a Lua file...")
            end
          ''''
        '';
        description = "Lua function to be called when the event(s) are triggered.";
      };

      command = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          Vim command to be executed when the event(s) are triggered.
          Cannot be defined if the `callback` option is already defined.
        '';
      };

      group = mkOption {
        type = nullOr str;
        default = null;
        example = "MyAutoCmdGroup";
        description = "An optional autocommand group to manage related autocommands.";
      };

      desc = mkOption {
        type = nullOr str;
        default = null;
        example = "Notify when saving a Lua file";
        description = "A description for the autocommand.";
      };

      once = mkOption {
        type = bool;
        default = false;
        description = "Whether to run the autocommand only once.";
      };

      nested = mkOption {
        type = bool;
        default = false;
        description = "Whether to allow nested autocommands to trigger.";
      };
    };
  };

  autogroupType = submodule {
    options = {
      enable =
        mkEnableOption ""
        // {
          default = true;
          description = "Whether to enable this autocommand group.";
        };

      name = mkOption {
        type = str;
        example = "MyAutoCmdGroup";
        description = "The name of the autocommand group.";
      };

      clear = mkOption {
        type = bool;
        default = true;
        description = ''
          Whether to clear existing autocommands in this group before defining new ones.
          This helps avoid duplicate autocommands.
        '';
      };
    };
  };

  cfg = config.vim;
in {
  options.vim = {
    augroups = mkOption {
      type = listOf autogroupType;
      default = [];
      description = ''
        A list of Neovim autogroups, which are used to organize and manage related
        autocommands together. Groups allow multiple autocommands to be cleared
        or redefined collectively, preventing duplicate definitions.

        Each autogroup consists of a name and a boolean indicating whether to clear
        existing autocommands.
      '';
    };

    autocmds = mkOption {
      type = listOf autocommandType;
      default = [];
      description = ''
        A list of Neovim autocommands to be registered.

        Each entry defines an autocommand, specifying events, patterns, a callback or Vim
        command, an optional group, a description, and execution settings.
      '';
    };
  };

  config = {
    vim = let
      enabledAutocommands = filter (cmd: cmd.enable) cfg.autocmds;
      enabledAutogroups = filter (au: au.enable) cfg.augroups;
    in {
      luaConfigRC = {
        augroups = entryBetween ["autocmds"] ["pluginConfigs"] (optionalString (enabledAutogroups != []) ''
          local nvf_autogroups = {}
          for _, group in ipairs(${toLuaObject enabledAutogroups}) do
            if group.name then
              nvf_autogroups[group.name] = { clear = group.clear }
            end
          end

          for group_name, options in pairs(nvf_autogroups) do
            vim.api.nvim_create_augroup(group_name, options)
          end
        '');

        autocmds = entryAfter ["pluginConfigs"] (optionalString (enabledAutocommands != []) ''
          local nvf_autocommands = ${toLuaObject enabledAutocommands}
          for _, autocmd in ipairs(nvf_autocommands) do
            vim.api.nvim_create_autocmd(
              autocmd.event,
              {
                group     = autocmd.group,
                pattern   = autocmd.pattern,
                buffer    = autocmd.buffer,
                desc      = autocmd.desc,
                callback  = autocmd.callback,
                command   = autocmd.command,
                once      = autocmd.once,
                nested    = autocmd.nested
              }
            )
          end
        '');
      };
    };

    assertions = [
      {
        assertion = builtins.all (cmd: (cmd.command == null || cmd.callback == null)) cfg.autocmds;
        message = "An autocommand cannot have both 'command' and 'callback' defined at the same time.";
      }
    ];
  };
}
