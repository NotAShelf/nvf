{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  imports = [
    ./gitsigns
    ./hunk-nvim
    ./vim-fugitive
    ./git-conflict
    ./gitlinker-nvim
    ./neogit
    ./octo-nvim
  ];

  options.vim.git = {
    enable = mkEnableOption ''
      git integration suite.

      Enabling this option will enable the following plugins:

      * gitsigns
      * hunk-nvim
      * vim-fugitive
      * git-conflict
      * gitlinker-nvim
      * octo-nvim
    '';
  };
}
