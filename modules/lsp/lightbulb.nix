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
    lightbulb = {
      enable = mkEnableOption "lightbulb for code actions. Requires emoji font";
    };
  };

  config = mkIf (cfg.enable && cfg.lightbulb.enable) {
    vim.startPlugins = ["nvim-lightbulb"];

    vim.configRC.lightbulb = nvim.dag.entryAnywhere ''
      autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
    '';

    vim.luaConfigRC.lightbulb = nvim.dag.entryAnywhere ''
      -- Enable trouble diagnostics viewer
      require'nvim-lightbulb'.setup()
    '';
  };
}
