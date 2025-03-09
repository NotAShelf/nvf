{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (builtins) any attrValues;

  cfg = config.vim.languages.tex;
in {
  imports = [
    ./texlab.nix
  ];

  config = mkIf (cfg.enable && (any (x: x.enable) (attrValues cfg.lsp))) {
    vim.lsp.lspconfig.enable = true; # Enable lspconfig when any of the lsps are enabled
  };
}
