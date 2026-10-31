{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str enum float;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.meta) getExe;
  mkMappingOption = config.vim.lib.mkMappingOption "Copilot";

  cfg = config.vim.assistant.copilot;
in {
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
      server = {
        custom_server_filepath = mkOption {
          type = str;
          default = getExe pkgs.copilot-language-server;
          description = ''
            Path to the GitHub Copilot language server executable.
            Recommended to leave as default.
          '';
        };
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
        jumpPrev = mkMappingOption "Jump to previous suggestion" "[[";
        jumpNext = mkMappingOption "Jump to next suggestion" "]]";
        accept = mkMappingOption "Accept suggestion" "<CR>";
        refresh = mkMappingOption "Refresh suggestions" "gr";
        open = mkMappingOption "Open suggestions" "<M-CR>";
      };
      suggestion = {
        accept = mkMappingOption "Accept suggestion" "<M-l>";
        acceptWord = mkMappingOption "Accept next word" null;
        acceptLine = mkMappingOption "Accept next line" null;
        prev = mkMappingOption "Previous suggestion" "<M-[>";
        next = mkMappingOption "Next suggestion" "<M-]>";
        dismiss = mkMappingOption "Dismiss suggestion" "<C-]>";
      };
    };
  };
}
