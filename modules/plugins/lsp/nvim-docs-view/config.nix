{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp.nvim-docs-view;

  inherit (options.vim.lsp.nvim-docs-view) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      lsp.enable = true;
      startPlugins = ["nvim-docs-view"];

      pluginRC.nvim-docs-view = entryAnywhere ''
        require("docs-view").setup ${toLuaObject cfg.setupOpts}
      '';

      keymaps = [
        (mkKeymap "n" cfg.mappings.viewToggle "<cmd>DocsViewToggle<CR>" {desc = mappings.viewToggle.description;})
        (mkKeymap "n" cfg.mappings.viewUpdate "<cmd>DocsViewUpdate<CR>" {desc = mappings.viewUpdate.description;})
      ];
    };
  };
}
