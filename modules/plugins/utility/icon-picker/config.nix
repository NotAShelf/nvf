{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.icon-picker;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "icon-picker-nvim"
      "dressing-nvim"
    ];

    vim.luaConfigRC.icon-picker = entryAnywhere ''
      require("icon-picker").setup({
        disable_legacy_commands = true
      })
    '';
  };
}
