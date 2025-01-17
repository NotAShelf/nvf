{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.completion;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-completion"];

    pluginRC.mini-completion = entryAnywhere ''
      require("mini.completion").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
