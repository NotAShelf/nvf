_: {
  imports = [
    # nvim lsp support
    ./config.nix
    ./module.nix

    ./lspconfig
    ./lspsaga
    ./null-ls

    # lsp plugins
    ./lspsaga
    ./nvim-code-action-menu
    ./trouble
    ./lsp-signature
    ./lightbulb
    ./lspkind
    ./lsplines
    ./nvim-docs-view
  ];
}
