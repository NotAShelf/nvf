{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) mkSetBinding addDescriptionsToMappings pushDownDefault;

  cfg = config.vim.lsp;

  self = import ./nvim-code-action-menu.nix {inherit lib;};
  mappingDefinitions = self.options.vim.lsp.nvimCodeActionMenu.mappings;
  mappings = addDescriptionsToMappings cfg.nvimCodeActionMenu.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.nvimCodeActionMenu.enable) {
    vim = {
      startPlugins = ["nvim-code-action-menu"];

      maps.normal = mkSetBinding mappings.open ":CodeActionMenu<CR>";

      binds.whichKey.register = pushDownDefault {
        "<leader>c" = "+CodeAction";
      };

      luaConfigRC.code-action-menu = entryAnywhere ''
        -- border configuration
        vim.g.code_action_menu_window_border = '${config.vim.ui.borders.plugins.code-action-menu.style}'

        -- show individual sections of the code action menu
        ${lib.optionalString cfg.nvimCodeActionMenu.show.details "vim.g.code_action_menu_show_details = true"}
        ${lib.optionalString cfg.nvimCodeActionMenu.show.diff "vim.g.code_action_menu_show_diff = true"}
        ${lib.optionalString cfg.nvimCodeActionMenu.show.actionKind "vim.g.code_action_menu_show_action_kind = true"}
      '';
    };
  };
}
