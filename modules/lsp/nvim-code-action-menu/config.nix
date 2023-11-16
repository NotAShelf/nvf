{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf mkSetBinding nvim;

  cfg = config.vim.lsp;

  self = import ./nvim-code-action-menu.nix {inherit lib;};

  mappingDefinitions = self.options.vim.lsp.nvimCodeActionMenu.mappings;
  mappings = addDescriptionsToMappings cfg.nvimCodeActionMenu.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.nvimCodeActionMenu.enable) {
    vim.startPlugins = ["nvim-code-action-menu"];

    vim.maps.normal = mkSetBinding mappings.open ":CodeActionMenu<CR>";

    vim.luaConfigRC.code-action-menu = nvim.dag.entryAnywhere ''
      -- border configuration
      vim.g.code_action_menu_window_border = '${config.vim.ui.borders.plugins.code-action-menu.style}'

      -- show individual sections of the code action menu
      ${lib.optionalString (cfg.nvimCodeActionMenu.show.details) "vim.g.code_action_menu_show_details = true"}
      ${lib.optionalString (cfg.nvimCodeActionMenu.show.diff) "vim.g.code_action_menu_show_diff = true"}
      ${lib.optionalString (cfg.nvimCodeActionMenu.show.actionKind) "vim.g.code_action_menu_show_action_kind = true"}
    '';
  };
}
