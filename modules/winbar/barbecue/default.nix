{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.winbar.barbecue;
in {
  options.vim.winbar.barbecue = {
    enable = mkEnableOption "Enable barbecue.nvim";
  };

  config = (mkIf cfg.enable) {
    vim.startPlugins =
      [
        "barbecue-nvim"
        "nvim-navic"
      ]
      ++ optional (config.vim.visuals.nvimWebDevicons.enable) "nvim-web-devicons";

    vim.luaConfigRC.barbecue-nvim = nvim.dag.entryAnywhere ''
      config = function()
        require("barbecue").setup()
      end,
    '';
  };
}
