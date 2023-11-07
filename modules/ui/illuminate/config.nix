{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.ui.illuminate;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-illuminate"];

    vim.luaConfigRC.vim-illuminate = nvim.dag.entryAnywhere ''
        require('illuminate').configure({
          filetypes_denylist = {
          'dirvish',
          'fugitive',
          'NvimTree',
          'TelescopePrompt',
        },
      })
    '';
  };
}
