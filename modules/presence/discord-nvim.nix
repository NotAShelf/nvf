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
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["presence-nvim"];

    vim.luaConfigRC.presence-nvim = nvim.dag.entryAnywhere ''
      -- Description of each option can be found in https://github.com/andweeb/presence.nvim444
      require("presence").setup({
          -- General options
          auto_update         = true,
          neovim_image_text   = "The One True Text Editor",
          main_image          = "neovim",
          client_id           = "793271441293967371",
          log_level           = nil,
          debounce_timeout    = 10,
          enable_line_number  = false,
          blacklist           = {},
          buttons             = true,
          file_assets         = {},
          show_time           = true,

          -- Rich Presence text options
          editing_text        = "Editing %s",
          file_explorer_text  = "Browsing %s",
          git_commit_text     = "Committing changes",
          plugin_manager_text = "Managing plugins",
          reading_text        = "Reading %s",
          workspace_text      = "Working on %s",
          line_number_text    = "Line %s out of %s",
      })
    '';
  };
}
