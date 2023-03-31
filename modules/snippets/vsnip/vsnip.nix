{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.snippets.vsnip = {
    enable = mkEnableOption "Enable vim-vsnip";
  };
}
