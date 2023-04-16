{...}: {
  imports = [
    # nvim lsp support
    ./config.nix
    ./module.nix

    # lsp plugins
    ./lspsaga
    ./nvim-code-action-menu
    ./trouble
    ./lsp-signature
    ./lightbulb

    # language specific modules
    ./flutter-tools-nvim # dart & flutter
    ./elixir # elixir
  ];
}
