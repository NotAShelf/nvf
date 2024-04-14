{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.git.vim-fugitive = {
    enable = mkEnableOption "vim-fugitive" // {default = config.vim.git.enable;};

    # TODO: sane default keybinds for vim-fugitive
    # mappings = {};
  };
}
