{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption literalExpression mkOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.lists) optionals;
  inherit (lib.types) listOf str;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.spellChecking;
in {
  options.vim.spellChecking = {
    enable = mkEnableOption "neovim's built-in spellchecking";
    languages = mkOption {
      type = listOf str;
      default = ["en"];
      example = literalExpression ''["en" "de"]'';
      description = "The languages to be used for spellchecking";
    };
  };

  config = mkIf cfg.enable {
    vim = {
      configRC.spellchecking = entryAfter ["basic"] ''
        " Spellchecking
        set spell
        set spelllang=${concatStringsSep "," cfg.languages}
      '';
    };
  };
}
