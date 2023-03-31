{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    nvimCodeActionMenu = {
      enable = mkEnableOption "nvim code action menu";
    };
  };
}
