{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.markdown;
in {
  options.vim.markdown = {
    enable = mkEnableOption "Enable markdown tools and plugins";
  };

  config = mkIf (cfg.enable) {
    /*
    ...
    */
  };
}
