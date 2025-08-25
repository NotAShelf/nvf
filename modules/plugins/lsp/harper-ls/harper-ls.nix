{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) anything attrsOf;
in {
  options.vim.lsp.harper-ls = {
    enable = mkEnableOption "Harper grammar checking LSP";
    settings = mkOption {
      type = attrsOf anything;
      default = {};
      example = {
        userDictPath = "";
        workspaceDictPath = "";
        fileDictPath = "";
        linters = {
          BoringWords = true;
          PossessiveNoun = true;
          SentenceCapitalization = false;
          SpellCheck = false;
        };
        codeActions = {
          ForceStable = false;
        };
        markdown = {
          IgnoreLinkTitle = false;
        };
        diagnosticSeverity = "hint";
        isolateEnglish = false;
        dialect = "American";
        maxFileLength = 120000;
        ignoredLintsPath = {};
      };
      description = "Settings to pass to harper-ls";
    };
  };
}
