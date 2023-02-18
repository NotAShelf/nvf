{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.presence.presence-nvim;
in {
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

  config = mkIf cfg.enable {
    vim.startPlugins = ["presence-nvim"];

    vim.luaConfigRC.presence-nvim = nvim.dag.entryAnywhere ''
      -- Description of each option can be found in https://github.com/andweeb/presence.nvim
      require("presence").setup({
          -- General options
          auto_update         = true,
          neovim_image_text   = ${cfg.image_text},
          main_image          = ${cfg.main_image},
          client_id           = ${cfg.client_id},
          log_level           = nil,
          debounce_timeout    = 10,
          enable_line_number  = ${boolToString cfg.enable_line_number},
          blacklist           = {},
          buttons             = ${boolToString cfg.buttons},
          file_assets         = {},
          show_time           = ${boolToString cfg.show_time},

          -- Rich Presence text options
          editing_text        = ${cfg.rich_presence.editing_text},
          file_explorer_text  = ${cfg.rich_presence.file_explorer_text},
          git_commit_text     = ${cfg.rich_presence.git_commit_text},
          plugin_manager_text = ${cfg.rich_presence.plugin_manager_text},
          reading_text        = ${cfg.rich_presence.reading_text},
          workspace_text      = ${cfg.rich_presence.workspace_text},
          line_number_text    = ${cfg.rich_presence.line_number_text},
      })
    '';
  };
}
