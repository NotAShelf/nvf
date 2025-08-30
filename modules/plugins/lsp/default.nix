{
  imports = [
    # nvim lsp support
    ./config.nix
    ./module.nix

    ./lspconfig
    ./lspsaga
    ./null-ls
    ./harper-ls

    # lsp plugins
    ./lspsaga
    ./trouble
    ./lsp-signature
    ./lightbulb
    ./otter
    ./lspkind
    ./nvim-docs-view
  ];
}
