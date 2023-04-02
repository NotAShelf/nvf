{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.nvimCodeActionMenu.enable) {
    vim.startPlugins = ["nvim-code-action-menu"];

    vim.nnoremap = {
      "<silent><leader>ca" = ":CodeActionMenu<CR>";
    };
  };
}
