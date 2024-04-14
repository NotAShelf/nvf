{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.spellcheck.vim-dirtytalk = {
    enable = mkEnableOption "vim-dirtytalk, a wordlist for programmers, that includes programming words";
  };
}
