{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;

  cfg = config.vim.repl.conjure;
in {
  options.vim.repl.conjure = {
    enable = mkEnableOption "Conjure";
  };

  config = mkIf cfg.enable {
    vim.lazy.plugins.conjure = {
      package = pkgs.vimPlugins.conjure;
      ft = [
        "clojure"
        "fennel"
        "janet"
        "hy"
        "julia"
        "racket"
        "scheme"
        "lua"
        "lisp"
        "python"
        "rust"
        "sql"
        "javascript"
        "typescript"
        "php"
        "r"
      ];
      cmd = [
        "ConjureSchool"
        "ConjureEval"
        "ConjureConnect"
        "ConjureClientState"
      ];
    };
  };
}
