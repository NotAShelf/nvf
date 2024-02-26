{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";
  };
}
