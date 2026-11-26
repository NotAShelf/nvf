{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit
    (lib.types)
    bool
    enum
    int
    str
    ;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.preview.livePreview = {
    enable = mkEnableOption "live preview in a web browser with live-preview.nvim";

    setupOpts = mkPluginSetupOption "live-preview.nvim" {
      port = mkOption {
        type = int;
        default = 5500;
        description = "Port to run the live preview server on.";
      };

      browser = mkOption {
        type = str;
        default = "default";
        example = "firefox";
        description = "Terminal command to open the browser for live-previewing (eg. `firefox`, `flatpak run com.vivaldi.Vivaldi`). By default, it will use the system's default browser.";
      };

      dynamic_root = mkOption {
        type = bool;
        default = false;
        description = "If `true`, the root directory of the server will be the parent directory of the current file. Otherwise, it will be the current directory.";
      };

      sync_scroll = mkOption {
        type = bool;
        default = true;
        description = "If `true`, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.";
      };

      picker = mkOption {
        type = enum [
          ""
          "telescope"
          "fzf-lua"
          "mini.pick"
          "snacks.picker"
          "vim.ui.select"
        ];
        default = "";
        description = "Picker to use for opening files. 5 choices are available: `telescope`, `fzf-lua`, `mini.pick`, `snacks.picker` or `vim.ui.select`. If `\"\"`, the plugin looks for the first available picker when you call the `pick` command.";
      };

      address = mkOption {
        type = str;
        default = "127.0.0.1";
        description = "Hostname/IP-address to bind the server to. Default: `127.0.0.1`.";
      };
    };
  };
}
