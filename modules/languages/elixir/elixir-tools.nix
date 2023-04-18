{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.languages.elixir = {
    enable = mkEnableOption "elixir support";
  };
}
