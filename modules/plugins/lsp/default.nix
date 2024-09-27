{
  imports = [
    # nvim lsp support
    ./config.nix
    ./module.nix

    ./lspconfig
    ./lspsaga
    ./null-ls

    # lsp plugins
    ./lspsaga
    ./trouble
    ./lsp-signature
    ./lightbulb
    ./otter
    ./lspkind
    ./lsplines
    ./nvim-docs-view
  ];
}
