{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool str listOf;
in {
  options.vim.utility.preview = {
    markdownPreview = {
      enable = mkEnableOption "Markdown preview in neovim with markdown-preview.nvim";

      autoStart = mkOption {
        type = bool;
        default = false;
        description = "Automatically open the preview window after entering a Markdown buffer";
      };

      autoClose = mkOption {
        type = bool;
        default = true;
        description = "Automatically close the preview window after leaving a Markdown buffer";
      };

      lazyRefresh = mkOption {
        type = bool;
        default = false;
        description = "Only update preview when saving or leaving insert mode";
      };

      filetypes = mkOption {
        type = listOf str;
        default = ["markdown"];
        description = "Allowed filetypes";
      };

      alwaysAllowPreview = mkOption {
        type = bool;
        default = false;
        description = "Allow preview on all filetypes";
      };

      broadcastServer = mkOption {
        type = bool;
        default = false;
        description = "Allow for outside and network wide connections";
      };

      customIP = mkOption {
        type = str;
        default = "";
        description = "IP-address to use";
      };

      customPort = mkOption {
        type = str;
        default = "";
        description = "Port to use";
      };
    };
  };
}
