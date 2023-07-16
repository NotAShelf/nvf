{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";
  };
}
