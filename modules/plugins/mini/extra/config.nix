{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.mini.extra;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-extra"];

    pluginRC.mini-extra = entryAnywhere ''
      require("mini.extra").setup()
    '';
  };
}
