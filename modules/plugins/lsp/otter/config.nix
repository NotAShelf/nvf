{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.otter.enable) {
    vim = {
      startPlugins = ["otter"];

      pluginRC.trouble = entryAnywhere ''
        -- Enable Otter
        require("otter").setup {}
      '';
    };
  };
}
