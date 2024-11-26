{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) bool int str enum nullOr listOf;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports =
    [
      (mkRemovedOptionModule ["vim" "presence" "presence-nvim"] ''
        The option vim.presence.presence-nvim has been deprecated in favor of the new
        neocord module. Options provided by the plugin remain mostly the same, but manual
        migration is required.

        Please see neocord documentation and options page on the **nvf** manual
        for more information
      '')
    ]
    ++ (map
      (optName: mkRenamedOptionModule ["vim" "presence" "neocord" "rich_presence" optName] ["vim" "presence" "neocord" "setupOpts" optName])
      ["debounce_timeout" "blacklist" "show_time" "editing_text" "file_explorer_text" "git_commit_text" "plugin_manager_text" "reading_text" "workspace_text" "line_number_text" "terminal_text"])
    ++ (map
      (optName: mkRenamedOptionModule ["vim" "presence" "neocord" optName] ["vim" "presence" "neocord" "setupOpts" optName])
      ["logo" "logo_tooltip" "main_image" "client_id" "log_level" "debounce_timeout" "blacklist" "show_time"]);

  options.vim.presence.neocord = {
    enable = mkEnableOption "neocord plugin for discord rich presence";

    setupOpts = mkPluginSetupOption "neocord" {
      logo = mkOption {
        type = str; # TODO: can the default be documented better, maybe with an enum?
        default = "auto";
        description = ''
          Logo to be displayed on the RPC item

          This must be either "auto" or an URL to your image of choice
        '';
      };

      logo_tooltip = mkOption {
        type = str;
        default = "The One True Text Editor";
        description = "Text displayed when hovering over the Neovim image";
      };

      main_image = mkOption {
        type = enum ["language" "logo"];
        default = "language";
        description = "Main image to be displayed";
      };

      client_id = mkOption {
        type = str;
        default = "1157438221865717891";
        description = "Client ID of the application";
      };

      log_level = mkOption {
        type = nullOr (enum ["debug" "info" "warn" "error"]);
        default = null;
        description = "Log level to be used by the plugin";
      };

      debounce_timeout = mkOption {
        type = int;
        default = 10;
        description = "Number of seconds to debounce events";
      };

      auto_update = mkOption {
        type = bool;
        default = true;
        description = "Automatically update the presence";
      };

      enable_line_number = mkOption {
        type = bool;
        default = false;
        description = "Show line number on the RPC item";
      };

      show_time = mkOption {
        type = bool;
        default = true;
        description = "Show time on the RPC item";
      };

      blacklist = mkOption {
        type = listOf str;
        default = [];
        example = literalExpression ''["Alpha"]'';
        description = "List of filetypes to ignore";
      };

      editing_text = mkOption {
        type = str;
        default = "Editing %s";
        description = "Text displayed when editing a file";
      };

      file_explorer_text = mkOption {
        type = str;
        default = "Browsing %s";
        description = "Text displayed when browsing files";
      };

      git_commit_text = mkOption {
        type = str;
        default = "Committing changes";
        description = "Text displayed when committing changes";
      };

      plugin_manager_text = mkOption {
        type = str;
        default = "Managing plugins";
        description = "Text displayed when managing plugins";
      };

      reading_text = mkOption {
        type = str;
        default = "Reading %s";
        description = "Text displayed when reading a file";
      };

      workspace_text = mkOption {
        type = str;
        default = "Working on %s";
        description = "Text displayed when working on a project";
      };

      line_number_text = mkOption {
        type = str;
        default = "Line %s out of %s";
        description = "Text displayed when showing line number";
      };

      terminal_text = mkOption {
        type = str;
        default = "Working on the terminal";
        description = "Text displayed when working on the terminal";
      };
    };
  };
}
