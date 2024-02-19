{lib, ...}: let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types) types;
in {
  options.vim = {
    spellChecking = {
      enable = mkEnableOption "neovim's built-in spellchecking";
      enableProgrammingWordList = mkEnableOption "vim-dirtytalk, a wordlist for programmers, that includes programming words";
      languages = mkOption {
        type = with types; listOf str;
        description = "The languages to be used for spellchecking";
        default = ["en"];
        example = ["en" "de"];
      };
    };
  };
}
