{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.trouble.enable) {
    vim.startPlugins = ["trouble"];

    vim.maps.normal = {
      "<leader>xx" = {action = "<cmd>TroubleToggle<CR>";};
      "<leader>lwd" = {action = "<cmd>TroubleToggle workspace_diagnostics<CR>";};
      "<leader>ld" = {action = "<cmd>TroubleToggle document_diagnostics<CR>";};
      "<leader>lr" = {action = "<cmd>TroubleToggle lsp_references<CR>";};
      "<leader>xq" = {action = "<cmd>TroubleToggle quickfix<CR>";};
      "<leader>xl" = {action = "<cmd>TroubleToggle loclist<CR>";};
    };

    vim.luaConfigRC.trouble = nvim.dag.entryAnywhere ''
      -- Enable trouble diagnostics viewer
      require("trouble").setup {}
    '';
  };
}
