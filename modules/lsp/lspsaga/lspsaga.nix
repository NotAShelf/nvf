{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {lspsaga = {enable = mkEnableOption "LSP Saga";};};

  config = mkIf (cfg.enable && cfg.lspsaga.enable) {
    vim.startPlugins = ["lspsaga"];

    vim.maps.visual = {
      "<silent><leader>ca" = {action = ":<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>";};
    };

    vim.maps.normal =
      {
        "<silent><leader>lf" = {action = "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>";};
        "<silent><leader>lh" = {action = "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>";};
        "<silent><C-f>" = {action = "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>";};
        "<silent><C-b>" = {action = "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>";};
        "<silent><leader>lr" = {action = "<cmd>lua require'lspsaga.rename'.rename()<CR>";};
        "<silent><leader>ld" = {action = "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>";};
        "<silent><leader>ll" = {action = "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>";};
        "<silent><leader>lc" = {action = "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>";};
        "<silent><leader>lp" = {action = "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>";};
        "<silent><leader>ln" = {action = "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>";};
      }
      // (
        if (!cfg.nvimCodeActionMenu.enable)
        then {
          "<silent><leader>ca" = {action = "<cmd>lua require('lspsaga.codeaction').code_action()<CR>";};
        }
        else {}
      )
      // (
        if (!cfg.lspSignature.enable)
        then {
          "<silent><leader>ls" = {action = "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>";};
        }
        else {}
      );

    vim.luaConfigRC.lspsage = nvim.dag.entryAnywhere ''
      -- Enable lspsaga
      local saga = require 'lspsaga'
      saga.init_lsp_saga()
    '';
  };
}
