{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.lists) isList;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  defaultServer = "zls";
  servers = {
    zls = {
      package = pkgs.zls;
      internalFormatter = true;
      lspConfig = ''
        lspconfig.zls.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/zls'}"
        }
        }
      '';
    };
  };

  cfg = config.vim.languages.zig;
in {
  options.vim.languages.zig = {
    enable = mkEnableOption "Zig language support";

    treesitter = {
      enable = mkEnableOption "Zig treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "zig";
    };

    lsp = {
      enable = mkEnableOption "Zig LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Zig LSP server to use";
      };

      package = mkOption {
        description = "ZLS package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.zls;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim = {
        lsp.lspconfig = {
          enable = true;
          sources.zig-lsp = servers.${cfg.lsp.server}.lspConfig;
        };

        # nvf handles autosaving already
        globals.zig_fmt_autosave = mkDefault 0;
      };
    })
  ]);
}
