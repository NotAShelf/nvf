{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe';
  inherit (lib.generators) mkLuaInline;
  inherit (lib.types) str bool enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "NvimTree";
in {
  options.vim.filetree.nvimTree = {
    enable = mkEnableOption "filetree via nvim-tree.lua";

    mappings = {
      toggle = mkMappingOption "Toggle" "<leader>t";
      refresh = mkMappingOption "Refresh" "<leader>tr";
      findFile = mkMappingOption "Find file" "<leader>tg";
      focus = mkMappingOption "Focus" "<leader>tf";
    };

    setupOpts = mkPluginSetupOption "Nvim Tree" {
      hijack_netrw = mkOption {
        default = true;
        description = "Prevents netrw from automatically opening when opening directories";
        type = bool;
      };

      disable_netrw = mkOption {
        default = false;
        description = "Disables netrw and replaces it with tree";
        type = bool;
      };

      diagnostics = {
        severity = {
          min = mkOption {
            description = "Minimum severity.";
            type = enum ["HINT" "INFO" "WARNING" "ERROR"];
            default = "HINT";
            apply = x: mkLuaInline "vim.diagnostic.severity.${x}";
          };

          max = mkOption {
            description = "Maximum severity.";
            type = enum ["HINT" "INFO" "WARNING" "ERROR"];
            default = "ERROR";
            apply = x: mkLuaInline "vim.diagnostic.severity.${x}";
          };
        };
      };

      trash = {
        cmd = mkOption {
          type = str;
          default = "${getExe' pkgs.glib "gio"} trash";
          description = "The command used to trash items";
        };
      };

      notify = {
        threshold = mkOption {
          type = enum ["ERROR" "WARNING" "INFO" "DEBUG"];
          description = "Specify minimum notification level, uses the values from `vim.log.levels`";
          default = "INFO";
          apply = x: mkLuaInline "vim.log.levels.${x}";
        };
      };
    };

    # kept for backwards compatibility
    openOnSetup = mkOption {
      default = true;
      description = "Open when vim is started on a directory";
      type = bool;
    };
  };
}
