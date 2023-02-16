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
  options.vim.notes.mind-nvim = {
    enable = mkEnableOption "The power of trees at your fingertips. ";
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "mind-nvim"
    ];

    vim.nnoremap = {
      "<C-o-m>" = ":MindOpenMain<CR>";
      "<C-o-p" = ":MindOpenProject<CR>";
      "<leader>mc" = ":MindClose<CR>";
    };

    vim.luaConfigRC.mind-nvim = nvim.dag.entryAnywhere ''
      require'mind'.setup()
    '';
  };
}
