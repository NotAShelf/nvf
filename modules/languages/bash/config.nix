{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.lists) isList;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.languages) diagnosticsToLua;

  cfg = config.vim.languages.bash;
  diagnosticsProviders = {
    shellcheck = {
      package = pkgs.shellcheck;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.shellcheck.with({
            command = "${pkg}/bin/shellcheck",
          })
        )
      '';
    };
  };

  formats = {
    shfmt = {
      package = pkgs.shfmt;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.shfmt.with({
            command = "${pkgs.shfmt}/bin/shfmt",
          })
        )
      '';
    };
  };

  servers = {
    bash-ls = {
      package = pkgs.nodePackages.bash-language-server;
      lspConfig = ''
        lspconfig.bashls.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/bash-language-server",  "start"}''
        };
        }
      '';
    };
  };
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.bash-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.bash-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = diagnosticsToLua {
        lang = "bash";
        config = cfg.extraDiagnostics.types;
        inherit diagnosticsProviders;
      };
    })
  ]);
}
