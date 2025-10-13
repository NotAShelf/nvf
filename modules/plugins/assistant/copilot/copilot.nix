{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) nullOr str enum float;
  inherit (lib.nvim.types) mkPluginSetupOption;

  cfg = config.vim.assistant.copilot;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "assistant" "copilot" "panel"] ["vim" "assistant" "copilot" "setupOpts" "panel"])
    (mkRenamedOptionModule ["vim" "assistant" "copilot" "copilotNodeCommand"] ["vim" "assistant" "copilot" "setupOpts" "copilot_node_command"])
    (mkRenamedOptionModule ["vim" "assistant" "copilot" "copilotNodePackage"] ["vim" "assistant" "copilot" "setupOpts" "copilot_node_command"])
  ];

  options.vim.assistant.copilot = {
    enable = mkEnableOption "GitHub Copilot AI assistant";
    cmp.enable = mkEnableOption "nvim-cmp integration for GitHub Copilot";

    setupOpts = mkPluginSetupOption "Copilot" {
      copilot_node_command = mkOption {
        type = str;
        default = "${lib.getExe pkgs.nodejs-slim}";
        description = ''
          The command that will be executed to initiate nodejs for GitHub Copilot.
          Recommended to leave as default.
        '';
      };
      panel = {
        enabled = mkEnableOption "Completion Panel" // {default = !cfg.cmp.enable;};
        layout = {
          position = mkOption {
            type = enum [
              "bottom"
              "top"
              "left"
              "right"
            ];
            default = "bottom";
            description = "Panel position";
          };
          ratio = mkOption {
            type = float;
            default = 0.4;
            description = "Panel size";
          };
        };
      };

      suggestion = {
        enabled = mkEnableOption "Suggestions" // {default = !cfg.cmp.enable;};
        # keymap = { };
      };
    };

    mappings = {
      panel = {
        jumpPrev = mkOption {
          type = nullOr str;
          default = "[[";
          description = "Jump to previous suggestion";
        };

        jumpNext = mkOption {
          type = nullOr str;
          default = "]]";
          description = "Jump to next suggestion";
        };

        accept = mkOption {
          type = nullOr str;
          default = "<CR>";
          description = "Accept suggestion";
        };

        refresh = mkOption {
          type = nullOr str;
          default = "gr";
          description = "Refresh suggestions";
        };

        open = mkOption {
          type = nullOr str;
          default = "<M-CR>";
          description = "Open suggestions";
        };
      };
      suggestion = {
        accept = mkOption {
          type = nullOr str;
          default = "<M-l>";
          description = "Accept suggestion";
        };

        acceptWord = mkOption {
          type = nullOr str;
          default = null;
          description = "Accept next word";
        };

        acceptLine = mkOption {
          type = nullOr str;
          default = null;
          description = "Accept next line";
        };

        prev = mkOption {
          type = nullOr str;
          default = "<M-[>";
          description = "Previous suggestion";
        };

        next = mkOption {
          type = nullOr str;
          default = "<M-]>";
          description = "Next suggestion";
        };

        dismiss = mkOption {
          type = nullOr str;
          default = "<C-]>";
          description = "Dismiss suggestion";
        };
      };
    };
  };
}
