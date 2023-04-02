{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    lightbulb = {
      enable = mkEnableOption "Lightbulb for code actions. Requires an emoji font";
    };
  };
}
