{lib, ...}:
with lib;
with builtins; {
  options.vim.comments.comment-nvim = {
    enable = mkEnableOption "Enable comment-nvim";

    mappings = {
      toggleCurrentLine = mkMappingOption "Toggle current line comment" "gcc";
      toggleCurrentBlock = mkMappingOption "Toggle current block comment" "gbc";

      toggleOpLeaderLine = mkMappingOption "Toggle line comment" "gc";
      toggleOpLeaderBlock = mkMappingOption "Toggle block comment" "gb";

      toggleSelectedLine = mkMappingOption "Toggle selected comment" "gc";
      toggleSelectedBlock = mkMappingOption "Toggle selected block" "gb";
    };
  };
}
