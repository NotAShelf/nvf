{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.comments.comment-nvim = {
    enable = mkEnableOption "comment-nvim";
  };
}
