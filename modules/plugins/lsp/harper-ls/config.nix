{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.harper-ls.enable) {
    vim.lsp.servers.harper-ls = {
      root_markers = [".git" ".harper-dictionary.txt"];
      cmd = [(getExe pkgs.harper) "--stdio"];
      settings = {harper-ls = cfg.harper-ls.settings;};
      filetypes =
        # <https://writewithharper.com/docs/integrations/language-server#Supported-Languages>
        [
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
    };
  };
}
