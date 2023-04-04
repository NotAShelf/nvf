{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.assistant.copilot = {
    enable = mkEnableOption "Enable GitHub Copilot";

    mappings = {
      panel = {
        jumpPrev = mkOption {
          type = types.nullOr types.str;
          default = "[[";
          description = "Jump to previous suggestion";
        };
        jumpNext = mkOption {
          type = types.nullOr types.str;
          default = "]]";
          description = "Jump to next suggestion";
        };
        accept = mkOption {
          type = types.nullOr types.str;
          default = "<CR>";
          description = "Accept suggestion";
        };
        refresh = mkOption {
          type = types.nullOr types.str;
          default = "gr";
          description = "Refresh suggestions";
        };
        open = mkOption {
          type = types.nullOr types.str;
          default = "<M-CR>";
          description = "Open suggestions";
        };
      };
      suggestion = {
        accept = mkOption {
          type = types.nullOr types.str;
          default = "<M-l>";
          description = "Accept suggetion";
        };
        acceptWord = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Accept next word";
        };
        acceptLine = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Accept next line";
        };
        prev = mkOption {
          type = types.nullOr types.str;
          default = "<M-[>";
          description = "Previous suggestion";
        };
        next = mkOption {
          type = types.nullOr types.str;
          default = "<M-]>";
          description = "Next suggestion";
        };
        dismiss = mkOption {
          type = types.nullOr types.str;
          default = "<C-]>";
          description = "Dismiss suggestion";
        };
      };
    };

    copilot_node_command = mkOption {
      type = types.str;
      default = "${lib.getExe pkgs.nodejs-slim-16_x}";
      description = "Path to nodejs";
    };
  };
}
