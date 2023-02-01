{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.snippets.vsnip;
in {
  options.vim.snippets.vsnip = {
    enable = mkEnableOption "Enable vim-vsnip";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-vsnip"];
  };
}
