{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./lsp.nix
    ./lspsaga.nix
    ./nvim-code-action-menu.nix
    ./trouble.nix
    ./lsp-signature.nix
    ./lightbulb.nix
  ];
}
