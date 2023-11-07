{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.session.nvim-session-manager = {
    enable = mkEnableOption "nvim-session-manager: manage sessions like folders in VSCode";

    mappings = {
      loadSession = mkOption {
        type = types.nullOr types.str;
        description = "Load session";
        default = "<leader>sl";
      };
      deleteSession = mkOption {
        type = types.nullOr types.str;
        description = "Delete session";
        default = "<leader>sd";
      };
      saveCurrentSession = mkOption {
        type = types.nullOr types.str;
        description = "Save current session";
        default = "<leader>sc";
      };
      loadLastSession = mkOption {
        type = types.nullOr types.str;
        description = "Load last session";
        default = "<leader>slt";
      };
    };

    usePicker = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not we should use dressing.nvim to build a session picker UI";
    };

    pathReplacer = mkOption {
      type = types.str;
      default = "__";
      description = "The character to which the path separator will be replaced for session files";
    };

    colonReplacer = mkOption {
      type = types.str;
      default = "++";
      description = "The character to which the colon symbol will be replaced for session files";
    };

    autoloadMode = mkOption {
      type = types.enum ["Disabled" "CurrentDir" "LastSession"];
      default = "LastSession";
      description = "Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession";
    };

    maxPathLength = mkOption {
      type = types.nullOr types.int;
      default = 80;
      description = "Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all";
    };

    autoSave = {
      lastSession = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically save last session on exit and on session switch";
      };

      ignoreNotNormal = mkOption {
        type = types.bool;
        default = true;
        description = "Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed";
      };

      ignoreDirs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "A list of directories where the session will not be autosaved";
      };

      ignoreFiletypes = mkOption {
        type = types.listOf types.str;
        default = ["gitcommit"];
        description = "All buffers of these file types will be closed before the session is saved";
      };

      ignoreBufTypes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "All buffers of these bufer types will be closed before the session is saved";
      };

      onlyInSession = mkOption {
        type = types.bool;
        default = false;
        description = "Always autosaves session. If true, only autosaves after a session is active";
      };
    };
  };
}
