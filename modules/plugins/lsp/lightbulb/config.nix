{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lightbulb.enable) {
    vim = {
      startPlugins = ["nvim-lightbulb"];

      pluginRC.lightbulb = entryAnywhere ''
        vim.api.nvim_command('autocmd CursorHold,CursorHoldI * lua require\'nvim-lightbulb\'.update_lightbulb()')

        -- Enable trouble diagnostics viewer
        require'nvim-lightbulb'.setup(${toLuaObject cfg.lightbulb.setupOpts})
      '';
    };
  };
}
