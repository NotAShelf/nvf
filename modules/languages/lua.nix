{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.go;

  defaultServer = "lua-ls";
  servers = {
    lua-ls = {
      package = pkgs.lua-language-server;
      lspConfig = ''
        lspconfig.lua_ls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then nvim.lua.expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}"}''
        };
        }
      '';
    };
  };
in {
  options.vim.languages.lua = {
    treesitter = {
      enable = mkOption "Enable Lua Treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = nvim.types.mkGrammarOption pkgs "lua";
    };
    lsp = {
      enable = mkOption "Enable Lua LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Lua LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Lua LSP server package, or the command to run as a list of strings";
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.lua-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
