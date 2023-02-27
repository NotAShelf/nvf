{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notes.mind-nvim;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "mind-nvim"
    ];

    vim.nnoremap = {
      "<leader>om" = ":MindOpenMain<CR>";
      "<leader>op" = ":MindOpenProject<CR>";
      "<leader>oc" = ":MindClose<CR>";
    };

    vim.luaConfigRC.mind-nvim = nvim.dag.entryAnywhere ''
      require'mind'.setup()
    '';
  };
}
