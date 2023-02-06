{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.icon-picker;
in {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "Nerdfonts icon picker for nvim";
  };

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
