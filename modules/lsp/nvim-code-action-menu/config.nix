{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;

  self = import ./nvim-code-action-menu.nix {inherit lib;};

  mappingDefinitions = self.options.vim.lsp.nvimCodeActionMenu.mappings;
  mappings = addDescriptionsToMappings cfg.nvimCodeActionMenu.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.nvimCodeActionMenu.enable) {
    vim.startPlugins = ["nvim-code-action-menu"];

    vim.maps.normal = mkSetBinding mappings.open ":CodeActionMenu<CR>";
  };
}
