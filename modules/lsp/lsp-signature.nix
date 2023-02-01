{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    lspSignature = {
      enable = mkEnableOption "lsp signature viewer";
    };
  };

  config = mkIf (cfg.enable && cfg.lspSignature.enable) {
    vim.startPlugins = ["lsp-signature"];

    vim.luaConfigRC.lsp-signature = nvim.dag.entryAnywhere ''
      -- Enable lsp signature viewer
      require("lsp_signature").setup()
    '';
  };
}
