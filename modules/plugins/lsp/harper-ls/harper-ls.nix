{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) anything attrsOf nullOr listOf str;
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
    filetypes = mkOption {
      type = nullOr (listOf str);
      # <https://writewithharper.com/docs/integrations/language-server#Supported-Languages>
      default = [
        "asciidoc"
        "c"
        "clojure"
        "cmake"
        "cpp"
        "cs"
        "daml"
        "dart"
        "gitcommit"
        "go"
        "haskell"
        "html"
        "ink"
        "java"
        "javascript"
        "javascriptreact"
        "kotlin"
        "lhaskell"
        "lua"
        "mail"
        "markdown"
        "nix"
        "php"
        "python"
        "ruby"
        "rust"
        "scala"
        "sh"
        "swift"
        "text"
        "toml"
        "typescript"
        "typescriptreact"
        "typst"
      ];
      description = "Filetypes to auto-attach LSP server in";
    };
  };
}
