{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.theme.twilight;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["twilight.nvim"];

      pluginRC.twilight = entryAnywhere ''
        require("twilight").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
