{lib, ...}:
with lib; {
  options.vim.snippets.vsnip = {
    enable = mkEnableOption "vim-vsnip: snippet LSP/VSCode's format";
  };
}
