{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.strings) optionalString;
  inherit (lib.types) either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.languages.lua;
in {
  options.vim.languages.lua = {
    enable = mkEnableOption "Lua language support";
    treesitter = {
      enable = mkEnableOption "Lua Treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "lua";
    };

    lsp = {
      enable = mkEnableOption "Lua LSP support via LuaLS" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "LuaLS package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.lua-language-server;
      };

      neodev.enable = mkEnableOption "neodev.nvim integration, useful for neovim plugin developers";
    };
  };

  config = mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.enable (mkMerge [
      (mkIf cfg.lsp.enable {
        vim.lsp.lspconfig.enable = true;
        vim.lsp.lspconfig.sources.lua-lsp = ''
          lspconfig.lua_ls.setup {
            capabilities = capabilities;
            on_attach = default_on_attach;
            ${optionalString cfg.lsp.neodev.enable "before_init = require('neodev.lsp').before_init;"}
            cmd = ${
            if isList cfg.lsp.package
            then expToLua cfg.lsp.package
            else ''{"${getExe cfg.lsp.package}"}''
          };
          }
        '';
      })

      (mkIf cfg.lsp.neodev.enable {
        vim.startPlugins = ["neodev-nvim"];
        vim.pluginRC.neodev = entryBefore ["lua-lsp"] ''
          require("neodev").setup({})
        '';
      })
    ]))
  ];
}
