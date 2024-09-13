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
    ./lspkind
    ./lsplines
    ./nvim-docs-view

    # Code Actions
    ./code-actions
  ];
}
