{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.ui.noice;
  tscfg = config.vim.treesitter;

  defaultGrammars = with pkgs.tree-sitter-grammars; [tree-sitter-vim tree-sitter-regex tree-sitter-lua tree-sitter-bash tree-sitter-markdown];
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "noice-nvim"
        "nui-nvim"
      ];

      treesitter.grammars = optionals tscfg.addDefaultGrammars defaultGrammars;

      pluginRC.noice-nvim = entryAnywhere ''
        require("noice").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
