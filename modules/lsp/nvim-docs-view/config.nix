{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;
  inherit (builtins) toString;

  cfg = config.vim.lsp.nvim-docs-view;
in {
  config = mkIf cfg.enable {
    vim = {
      lsp.enable = true;
      startPlugins = ["nvim-docs-view"];

      luaConfigRC.nvim-docs-view = nvim.dag.entryAnywhere ''
        require("docs-view").setup {
          position = "${cfg.position}",
          width = ${toString cfg.width},
          height = ${toString cfg.height},
          update_mode = "${cfg.updateMode}",
        }
      '';
    };
  };
}
