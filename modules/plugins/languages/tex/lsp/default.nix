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

  config =
    mkIf
    (
      cfg.enable # Check if nvf is enabled.
      && (any (x: x.enable) (attrValues cfg.lsp)) # Check if any of the LSPs have been enabled.
    )
    {
      vim.lsp.lspconfig.enable = lib.mkDefault true; # Enable lspconfig when any of the lsps are enabled
    };
}
