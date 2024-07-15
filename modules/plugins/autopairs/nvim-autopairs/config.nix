{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.autopairs;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-autopairs"];

    vim.pluginRC.autopairs = entryAnywhere ''
      require("nvim-autopairs").setup({ map_cr = ${boolToString (!config.vim.autocomplete.enable)} })
    '';
  };
}
