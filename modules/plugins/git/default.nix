{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  imports = [
    ./gitsigns
    ./vim-fugitive
    ./git-conflict
    ./gitlinker-nvim
    ./neogit
  ];

  options.vim.git = {
    enable = mkEnableOption ''
      git integration suite.

      Enabling this option will enable the following plugins:
      * gitsigns
      * vim-fugitive
      * git-conflict
      * gitlinker-nvim
    '';
  };
}
