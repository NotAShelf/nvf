{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.lsp;
in {
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
