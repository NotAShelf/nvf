{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption literalExpression mkOption;
  inherit (lib.strings) concatStringsSep optionalString;
  inherit (lib.lists) optionals;
  inherit (lib.types) listOf str;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.spellChecking;
  languages = cfg.languages ++ optionals cfg.enableProgrammingWordList ["programming"];
in {
  options.vim.spellChecking = {
    enable = mkEnableOption "neovim's built-in spellchecking";
    enableProgrammingWordList = mkEnableOption "vim-dirtytalk, a wordlist for programmers, that includes programming words";
    languages = mkOption {
      type = listOf str;
      default = ["en"];
      example = literalExpression ''["en" "de"]'';
      description = "The languages to be used for spellchecking";
    };
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins = optionals cfg.spellChecking.enableProgrammingWordList ["vim-dirtytalk"];
      configRC.spellchecking = entryAfter ["basic"] ''
        ${optionalString cfg.enable ''
          set spell
          set spelllang=${concatStringsSep "," languages}
        ''}
      '';
    };
  };
}
