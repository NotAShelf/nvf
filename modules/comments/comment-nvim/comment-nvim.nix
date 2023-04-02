{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.comments.comment-nvim = {
    enable = mkEnableOption "Enable comment-nvim";
  };
}
