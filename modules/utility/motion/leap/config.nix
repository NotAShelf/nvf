{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.utility.motion.leap;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "leap-nvim"
      "vim-repeat"
    ];

    vim.nnoremap = {
      "<leader>h" = "<cmd> HopPattern<CR>";
    };

    vim.luaConfigRC.leap-nvim = nvim.dag.entryAnywhere ''
      require('leap').add_default_mappings()
      -- TODO: register custom keybinds
      -- require('leap').leap {
      --   opts = {
      --     labels = {}
      --   }
      -- }
    '';
  };
}
