{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.lua) nullString;
  inherit (lib.nvim.dag) entryAfter;

  inherit (config.vim) treesitter;
  cfg = treesitter.context;
in {
  config = mkIf (treesitter.enable && cfg.enable) {
    vim.startPlugins = ["nvim-treesitter-context"];

    vim.luaConfigRC.treesitter-context = entryAfter ["treesitter"] ''
      require'treesitter-context'.setup {
        enable = true,
        max_lines = ${toString cfg.maxLines},
        min_window_height = ${toString cfg.minWindowHeight},
        line_numbers = ${boolToString cfg.lineNumbers},
        multiline_threshold = ${toString cfg.multilineThreshold},
        trim_scope = '${cfg.trimScope}',
        mode = '${cfg.mode}',
        separator = ${nullString cfg.separator},
        z_index = ${toString cfg.zindex},
      }
    '';
  };
}
