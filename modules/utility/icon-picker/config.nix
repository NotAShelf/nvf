{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.utility.icon-picker;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "icon-picker-nvim"
      "dressing-nvim"
    ];

    vim.luaConfigRC.icon-picker = nvim.dag.entryAnywhere ''
      require("icon-picker").setup({
        disable_legacy_commands = true
      })
    '';
  };
}
