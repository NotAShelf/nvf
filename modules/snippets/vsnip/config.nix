{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.snippets.vsnip;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-vsnip"];
  };
}
