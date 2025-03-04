{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.strings) isString;
  inherit (lib.types) nullOr str bool int enum listOf either;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) luaInline mkPluginSetupOption;
in {
  imports = let
    renameSetupOpt = oldPath: newPath:
      mkRenamedOptionModule (["vim" "session" "nvim-session-manager"] ++ oldPath) (["vim" "session" "nvim-session-manager" "setupOpts"] ++ newPath);
  in [
    (renameSetupOpt ["pathReplacer"] ["path_replacer"])
    (renameSetupOpt ["colonReplacer"] ["colon_replacer"])
    (renameSetupOpt ["autoloadMode"] ["autoload_mode"])
    (renameSetupOpt ["maxPathLength"] ["max_path_length"])
    (renameSetupOpt ["autoSave" "lastSession"] ["autosave_last_session"])
    (renameSetupOpt ["autoSave" "ignoreNotNormal"] ["autosave_ignore_not_normal"])
    (renameSetupOpt ["autoSave" "ignoreDirs"] ["autosave_ignore_dirs"])
    (renameSetupOpt ["autoSave" "ignoreFiletypes"] ["autosave_ignore_filetypes"])
    (renameSetupOpt ["autoSave" "ignoreBufTypes"] ["autosave_ignore_buftypes"])
    (renameSetupOpt ["autoSave" "onlyInSession"] ["autosave_only_in_session"])
  ];

  options.vim.session.nvim-session-manager = {
    enable = mkEnableOption "nvim-session-manager: manage sessions like folders in VSCode";

    mappings = {
      loadSession = mkOption {
        type = nullOr str;
        description = "Load session";
        default = "<leader>sl";
      };

      deleteSession = mkOption {
        type = nullOr str;
        description = "Delete session";
        default = "<leader>sd";
      };

      saveCurrentSession = mkOption {
        type = nullOr str;
        description = "Save current session";
        default = "<leader>sc";
      };

      loadLastSession = mkOption {
        type = nullOr str;
        description = "Load last session";
        default = "<leader>slt";
      };
    };

    usePicker = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether we should use `dressing.nvim` to build a session picker UI
      '';
    };

    setupOpts = mkPluginSetupOption "which-key" {
      path_replacer = mkOption {
        type = str;
        default = "__";
        description = ''
          The character to which the path separator will be replaced for session files
        '';
      };

      colon_replacer = mkOption {
        type = str;
        default = "++";
        description = ''
          The character to which the colon symbol will be replaced for session files
        '';
      };

      autoload_mode = mkOption {
        type = either (enum ["Disabled" "CurrentDir" "LastSession"]) luaInline;
        # Variable 'sm' is defined in the pluginRC of nvim-session-manager. The
        # definition is as follows: `local sm = require('session_manager.config')`
        apply = val:
          if isString val
          then mkLuaInline "sm.AutoloadMode.${val}"
          else val;
        default = "LastSession";
        description = ''
          Define what to do when Neovim is started without arguments.

          Takes either one of `"Disabled"`, `"CurrentDir"`, `"LastSession` in which case the value
          will be inserted into `sm.AutoloadMode.<value>`, or an inline Lua value.
        '';
      };

      max_path_length = mkOption {
        type = nullOr int;
        default = 80;
        description = ''
          Shorten the display path if length exceeds this threshold.

          Use `0` if don't want to shorten the path at all
        '';
      };

      autosave_last_session = mkOption {
        type = bool;
        default = true;
        description = ''
          Automatically save last session on exit and on session switch
        '';
      };

      autosave_ignore_not_normal = mkOption {
        type = bool;
        default = true;
        description = ''
          Plugin will not save a session when no buffers are opened, or all of them are
          not writable or listed
        '';
      };

      autosave_ignore_dirs = mkOption {
        type = listOf str;
        default = [];
        description = "A list of directories where the session will not be autosaved";
      };

      autosave_ignore_filetypes = mkOption {
        type = listOf str;
        default = ["gitcommit"];
        description = ''
          All buffers of these file types will be closed before the session is saved
        '';
      };

      autosave_ignore_buftypes = mkOption {
        type = listOf str;
        default = [];
        description = ''
          All buffers of these buffer types will be closed before the session is saved
        '';
      };

      autosave_only_in_session = mkOption {
        type = bool;
        default = false;
        description = ''
          Always autosaves session. If `true`, only autosaves after a session is active
        '';
      };
    };
  };
}
