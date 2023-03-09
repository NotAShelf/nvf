{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.utility.hop;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["hop-nvim"];

    vim.nnoremap = {
      "<leader>h" = "<cmd> HopPattern<CR>";
    };

    vim.luaConfigRC.hop-nvim = nvim.dag.entryAnywhere ''
      require('hop').setup()
    '';
  };
}
