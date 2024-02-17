{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim boolToString;
  inherit (lib.nvim.lua) listToLuaTable;
  inherit (lib.strings) escapeNixString;
  inherit (builtins) toString;

  cfg = config.vim.presence.neocord;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["neocord"];

    vim.luaConfigRC.neocord = nvim.dag.entryAnywhere ''
      -- Description of each option can be found in https://github.com/IogaMaster/neocord#lua
      require("neocord").setup({
          -- General options
          logo                = "${cfg.logo}",
          logo_tooltip        = "${cfg.logo_tooltip}",
          main_image          = "${cfg.main_image}",
          client_id           = "${cfg.client_id}",
          log_level           = ${
        if cfg.log_level == null
        then "nil"
        else "${escapeNixString cfg.log_level}"
      },
          debounce_timeout    = ${toString cfg.debounce_timeout},
          blacklist           = ${listToLuaTable cfg.blacklist},
          show_time           = "${boolToString cfg.show_time}",

          -- Rich Presence text options
          editing_text        = "${cfg.rich_presence.editing_text}",
          file_explorer_text  = "${cfg.rich_presence.file_explorer_text}",
          git_commit_text     = "${cfg.rich_presence.git_commit_text}",
          plugin_manager_text = "${cfg.rich_presence.plugin_manager_text}",
          reading_text        = "${cfg.rich_presence.reading_text}",
          workspace_text      = "${cfg.rich_presence.workspace_text}",
          line_number_text    = "${cfg.rich_presence.line_number_text}",
          terminal_text       = "${cfg.rich_presence.terminal_text}",
      })
    '';
  };
}
