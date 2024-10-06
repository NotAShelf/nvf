{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.comments.comment-nvim = {
    enable = mkEnableOption "smart and powerful comment plugin for neovim comment-nvim";

    mappings = {
      toggleCurrentLine = mkMappingOption "Toggle current line comment" "gcc";
      toggleCurrentBlock = mkMappingOption "Toggle current block comment" "gbc";

      toggleOpLeaderLine = mkMappingOption "Toggle line comment" "gc";
      toggleOpLeaderBlock = mkMappingOption "Toggle block comment" "gb";

      toggleSelectedLine = mkMappingOption "Toggle selected comment" "gc";
      toggleSelectedBlock = mkMappingOption "Toggle selected block" "gb";
    };

    setupOpts = mkPluginSetupOption "Comment-nvim" {
      mappings = {
        basic = mkEnableOption "basic mappings";
        extra = mkEnableOption "extra mappings";
      };
    };
  };
}
