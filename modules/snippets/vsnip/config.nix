{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.vim.snippets.vsnip;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-vsnip"];
  };
}
