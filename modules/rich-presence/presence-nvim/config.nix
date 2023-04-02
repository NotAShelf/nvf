{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.presence.presence-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["presence-nvim"];

    vim.luaConfigRC.presence-nvim = nvim.dag.entryAnywhere ''
      -- Description of each option can be found in https://github.com/andweeb/presence.nvim
      require("presence").setup({
          -- General options
          auto_update         = true,
          neovim_image_text   = "${cfg.image_text}",
          main_image          = "${cfg.main_image}",
          client_id           = "${cfg.client_id}",
          log_level           = nil,
          debounce_timeout    = 10,
          enable_line_number  = "${boolToString cfg.enable_line_number}",
          blacklist           = {},
          buttons             = "${boolToString cfg.buttons}",
          file_assets         = {},
          show_time           = "${boolToString cfg.show_time}",

          -- Rich Presence text options
          editing_text        = "${cfg.rich_presence.editing_text}",
          file_explorer_text  = "${cfg.rich_presence.file_explorer_text}",
          git_commit_text     = "${cfg.rich_presence.git_commit_text}",
          plugin_manager_text = "${cfg.rich_presence.plugin_manager_text}",
          reading_text        = "${cfg.rich_presence.reading_text}",
          workspace_text      = "${cfg.rich_presence.workspace_text}",
          line_number_text    = "${cfg.rich_presence.line_number_text}",
      })
    '';
  };
}
