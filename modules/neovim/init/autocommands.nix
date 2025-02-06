{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) submodule attrsOf listOf str bool;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  autocommandType = submodule {
    options = {
      enable =
        mkEnableOption ""
        // {
          default = true;
          description = "Whether to enable this autocommand";
        };

      event = mkOption {
        type = listOf str;
        example = ["BufRead" "BufWritePre"];
        description = "The event(s) that trigger the autocommand.";
      };

      pattern = mkOption {
        type = listOf str;
        example = ["*.lua" "*.vim"];
        description = "The file pattern(s) that determine when the autocommand applies).";
      };

      callback = mkOption {
        type = luaInline;
        example = ''
          function()
              print("Saving a Lua file...")
          end,
        '';
        description = "The file pattern(s) that determine when the autocommand applies).";
      };

      command = mkOption {
        type = str;
        description = "Vim command string instead of a Lua function.";
      };

      group = mkOption {
        type = str;
        example = "MyAutoCmdGroup";
        description = "An optional autocommand group to manage related autocommands.";
      };

      desc = mkOption {
        type = str;
        example = "Notify when saving a Lua file";
        description = "A description for the autocommand.";
      };

      once = mkOption {
        type = bool;
        default = false;
        description = "Whether autocommand run only once.";
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
    autogroups = mkOption {
      type = listOf autogroupType;
      default = [];
      description = ''
        A list of Neovim autogroups, which are used to organize and manage related
        autocommands together. Groups allow multiple autocommands to be cleared
        or redefined collectively, preventing duplicate definitions.

        Each autogroup consists of a name, a boolean indicating whether to clear
        existing autocommands, and a list of associated autocommands.
      '';
    };

    autocommands = mkOption {
      type = listOf autocommandType;
      default = [];
      description = ''
        A list of Neovim autocommands to be registered. Each entry defines an
        autocommand, specifying events, patterns, and optional callbacks, commands,
        groups, and execution settings.
      '';
    };
  };

  config.vim = let
    enabledAutocommands = lib.filter (cmd: cmd.enable) cfg.autocommands;
  in {
    luaConfigRC = {
      autogroups = entryAfter ["pluginConfigs"] (lib.optionalString (enabledAutocommands != []) ''
        local nvf_autogroups = ${toLuaObject cfg.autogroups}

        for group_name, options in pairs(nvf_autogroups) do
          vim.api.nvim_create_augroup(group_name, options)
        end
      '');

      autocommands = entryAfter ["pluginConfigs"] (lib.optionalString (cfg.autocommands != []) ''
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
}
