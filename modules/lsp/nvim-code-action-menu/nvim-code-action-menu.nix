{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    nvimCodeActionMenu = {
      enable = mkEnableOption "Enable nvim code action menu";
    };
  };
}
