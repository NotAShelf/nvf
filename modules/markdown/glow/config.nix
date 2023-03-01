{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vim.markdown.glow;
in {
  config = (mkIf cfg.enable) {
    vim.startPlugins = [
      "glow-nvim"
    ];

    vim.globals = {
      "glow_binary_path" = "${pkgs.glow}/bin";
    };

    vim.configRC.glow-nvim = nvim.dag.entryAnywhere ''
      autocmd FileType markdown noremap <leader>pm :Glow<CR>
    '';

    vim.luaConfigRC.glow-nvim = nvim.dag.entryAnywhere ''
      require('glow').setup({
        -- use glow path from vim.globals
        path = vim.g.glow_binary_path,
        border = "${toString cfg.border}",
        pager = ${boolToString cfg.pager},
        width = 120,
      })
    '';
  };
}
