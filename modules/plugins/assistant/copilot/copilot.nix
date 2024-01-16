{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.vim.assistant.copilot;
in {
  options.vim.assistant.copilot = {
    enable = mkEnableOption "GitHub Copilot AI assistant";
    cmp.enable = mkEnableOption "nvim-cmp integration for GitHub Copilot";

    panel = {
      position = mkOption {
        type = types.enum [
          "bottom"
          "top"
          "left"
          "right"
        ];
        default = "bottom";
        description = "Panel position";
      };
      ratio = mkOption {
        type = types.float;
        default = 0.4;
        description = "Panel size";
      };
    };

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

    copilotNodeCommand = mkOption {
      type = types.str;
      default = "${lib.getExe cfg.copilotNodePackage}";
      description = ''
        The command that will be executed to initiate nodejs for GitHub Copilot.
        Recommended to leave as default.
      '';
    };

    copilotNodePackage = mkOption {
      type = with types; nullOr package;
      default = pkgs.nodejs-slim;
      description = ''
        The nodeJS package that will be used for GitHub Copilot. If you are using a custom node command
        you may want to set this option to null so that the package is not pulled from nixpkgs.
      '';
    };
  };
}
