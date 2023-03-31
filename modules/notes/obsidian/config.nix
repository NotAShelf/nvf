{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notes.obsidian;
  auto = config.vim.autocomplete;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "obsidian-nvim"
      "vim-markdown"
      "tabular"
    ];

    vim.luaConfigRC.obsidian = nvim.dag.entryAnywhere ''
      require("obsidian").setup({
        dir = "${cfg.dir}",
        completion = {
          nvim_cmp = ${
        if (auto.type == "nvim-cmp")
        then "true"
        else "false"
      }
        }
      })
    '';
  };
}
