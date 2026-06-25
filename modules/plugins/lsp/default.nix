{
  imports = [
    # nvim lsp support
    ./config.nix
    ./module.nix

    ./presets

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
    ./nvim-docs-view
  ];
}
