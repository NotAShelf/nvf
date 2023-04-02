{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.comments.kommentary;
in {
  options.vim.comments.kommentary = {
    enable = mkEnableOption "Enable kommentary";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "kommentary"
    ];

    vim.luaConfigRC.kommentary = nvim.dag.entryAnywhere ''
      require('kommentary.config').use_extended_mappings()
    '';
  };
}
