{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
in {
  options.vim.treesitter.context.enable = mkOption {
    type = types.bool;
    default = false;
    description = "enable function context [nvim-treesitter-context]";
  };

  config = mkIf (cfg.enable && cfg.context.enable) {
    vim.startPlugins = [
      "nvim-treesitter-context"
    ];

    vim.luaConfigRC.treesitter-context = nvim.dag.entryAnywhere ''
      -- Treesitter Context config
      require'treesitter-context'.setup {
        enable = true,
        throttle = true,
        max_lines = 0
      }
    '';
  };
}
