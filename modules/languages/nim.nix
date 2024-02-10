{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) isList nvim mkEnableOption mkOption types mkIf mkMerge;
  cfg = config.vim.languages.nim;

  defaultServer = "nimlsp";
  servers = {
    nimlsp = {
      package = pkgs.nimlsp;
      lspConfig = ''
        lspconfig.nimls.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then nvim.lua.expToLua cfg.lsp.package
          else ''
            {"${cfg.lsp.package}/bin/nimlsp"}
          ''
        };
        }
      '';
    };
  };

  defaultFormat = "nimpretty";
  formats = {
    nimpretty = {
      package = pkgs.nim;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.nimpretty.with({
            command = "${pkgs.nim}/bin/nimpretty",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.nim = {
    enable = mkEnableOption "Nim language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Nim treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "nim";
    };

    lsp = {
      enable = mkEnableOption "Nim LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Nim LSP server to use";
        type = types.str;
        default = defaultServer;
      };
      package = mkOption {
        description = "Nim LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.nimlsp]'';
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "Nim formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Nim formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = mkOption {
        description = "Nim formatter package";
        type = types.package;
        default = formats.${cfg.format.type}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !pkgs.stdenv.isDarwin;
          message = "Nim language support is only available on Linux";
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.nim-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.nim-format = formats.${cfg.format.type}.nullConfig;
    })
  ]);
}
