{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.dashboard.alpha;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "alpha";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "alpha-nvim"
    ];

    vim.luaConfigRC.alpha = nvim.dag.entryAnywhere ''
      require'alpha'.setup(require'alpha.themes.startify'.config)
    '';
  };
}
