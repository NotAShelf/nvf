{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";
  };
}
