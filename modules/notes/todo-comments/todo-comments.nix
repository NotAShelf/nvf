{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.notes.todo-comments = {
    enable = mkEnableOption "Enable todo-comments";

    patterns = {
      highlight = mkOption {
        type = types.str;
        default = ''[[.*<(KEYWORDS)(\([^\)]*\))?:]]'';
        description = "vim regex pattern used for highlighting comments";
      };

      search = mkOption {
        type = types.str;
        default = ''[[\b(KEYWORDS)(\([^\)]*\))?:]]'';
        description = "ripgrep regex pattern used for searching comments";
      };
    };
  };
}
