{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.comments.comment-nvim = {
    enable = mkEnableOption "smart and powerful comment plugin for neovim comment-nvim";

    mappings = {
      toggleCurrentLine = mkMappingOption config.vim.enableNvfKeymaps "Toggle current line comment" "gcc";
      toggleCurrentBlock = mkMappingOption config.vim.enableNvfKeymaps "Toggle current block comment" "gbc";

      toggleOpLeaderLine = mkMappingOption config.vim.enableNvfKeymaps "Toggle line comment" "gc";
      toggleOpLeaderBlock = mkMappingOption config.vim.enableNvfKeymaps "Toggle block comment" "gb";

      toggleSelectedLine = mkMappingOption config.vim.enableNvfKeymaps "Toggle selected comment" "gc";
      toggleSelectedBlock = mkMappingOption config.vim.enableNvfKeymaps "Toggle selected block" "gb";
    };

    setupOpts = mkPluginSetupOption "Comment-nvim" {
      mappings = {
        basic = mkEnableOption "basic mappings";
        extra = mkEnableOption "extra mappings";
      };
    };
  };
}
