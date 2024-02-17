{lib, ...}: let
  inherit (lib) types mkEnableOption mkOption;
in {
  options.vim.utility.preview = {
    markdownPreview = {
      enable = mkEnableOption "Markdown preview in neovim with markdown-preview.nvim";

      autoStart = mkOption {
        type = types.bool;
        default = false;
        description = "Automatically open the preview window after entering a Markdown buffer";
      };

      autoClose = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically close the preview window after leaving a Markdown buffer";
      };

      lazyRefresh = mkOption {
        type = types.bool;
        default = false;
        description = "Only update preview when saving or leaving insert mode";
      };

      filetypes = mkOption {
        type = with types; listOf str;
        default = ["markdown"];
        description = "Allowed filetypes";
      };

      alwaysAllowPreview = mkOption {
        type = types.bool;
        default = false;
        description = "Allow preview on all filetypes";
      };

      broadcastServer = mkOption {
        type = types.bool;
        default = false;
        description = "Allow for outside and network wide connections";
      };

      customIP = mkOption {
        type = types.str;
        default = "";
        description = "IP-address to use";
      };

      customPort = mkOption {
        type = types.str;
        default = "";
        description = "Port to use";
      };
    };
  };
}
