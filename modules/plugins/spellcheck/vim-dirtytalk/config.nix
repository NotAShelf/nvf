{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAfter;
  cfg = config.vim.spellcheck;
in {
  config = mkIf cfg.vim-dirtytalk.enable {
    vim = {
      startPlugins = ["vim-dirtytalk"];

      # vim-dirtytalk doesn't have any setup
      # but we would like to append programming to spelllang
      # as soon as possible while the plugin is enabled
      luaConfigRC.vim-dirtytalk = entryAfter ["basic"] ''
        -- append programming to spelllang
        vim.opt.spelllang:append("programming")
      '';
    };
  };
}
