{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.lsp;

  inherit (options.vim.lsp.otter-nvim) mappings;
in {
  config = mkIf (cfg.enable && cfg.otter-nvim.enable) {
    vim = {
      startPlugins = ["otter-nvim"];

      keymaps = [
        (mkKeymap "n" cfg.otter-nvim.mappings.toggle "<cmd>lua require'otter'.activate()<CR>" {desc = mappings.toggle.description;})
      ];

      pluginRC.otter-nvim = entryAnywhere ''
        -- Enable otter diagnostics viewer
        require("otter").setup(${toLuaObject cfg.otter-nvim.setupOpts})
      '';
    };
  };
}
