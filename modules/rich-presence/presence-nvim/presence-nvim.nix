{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.presence.presence-nvim = {
    enable = mkEnableOption "Enable presence.nvim plugin";

    image_text = mkOption {
      type = types.str;
      default = "The One True Text Editor";
      description = "Text displayed when hovering over the Neovim image";
    };

    main_image = mkOption {
      type = types.str;
      default = "neovim";
      description = "Main image to be displayed";
    };

    client_id = mkOption {
      type = types.str;
      default = "859194972255989790";
      description = "Client ID of the application";
    };
    auto_update = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically update the presence";
    };

    enable_line_number = mkOption {
      type = types.bool;
      default = false;
      description = "Show line number on the RPC item";
    };

    buttons = mkOption {
      type = types.bool;
      default = true;
      description = "Show buttons on the RPC item";
    };

    show_time = mkOption {
      type = types.bool;
      default = true;
      description = "Show time on the RPC item";
    };

    rich_presence = {
      editing_text = mkOption {
        type = types.str;
        default = "Editing %s";
        description = "Text displayed when editing a file";
      };

      file_explorer_text = mkOption {
        type = types.str;
        default = "Browsing %s";
        description = "Text displayed when browsing files";
      };

      git_commit_text = mkOption {
        type = types.str;
        default = "Committing changes";
        description = "Text displayed when committing changes";
      };

      plugin_manager_text = mkOption {
        type = types.str;
        default = "Managing plugins";
        description = "Text displayed when managing plugins";
      };

      reading_text = mkOption {
        type = types.str;
        default = "Reading %s";
        description = "Text displayed when reading a file";
      };

      workspace_text = mkOption {
        type = types.str;
        default = "Working on %s";
        description = "Text displayed when working on a project";
      };

      line_number_text = mkOption {
        type = types.str;
        default = "Line %s out of %s";
        description = "Text displayed when showing line number";
      };
    };
  };
}
