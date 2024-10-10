{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.languages) diagnosticsToLua;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.lists) isList;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.kotlin;

  defaultDiagnosticsProvider = ["ktlint"];
  diagnosticsProviders = {
    ktlint = {
      package = pkgs.ktlint;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.ktlint.with({
            command = "${getExe pkg}",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.kotlin = {
    enable = mkEnableOption "Kotlin/HCL support";

    treesitter = {
      enable = mkEnableOption "Kotlin treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "kotlin";
    };

    lsp = {
      enable = mkEnableOption "Kotlin LSP support" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "kotlin_language_server package with Kotlin runtime";
        type = package;
        example = literalExpression ''
          pkgs.symlinkJoin {
              name = "kotlin-language-server-wrapped";
              paths = [pkgs.kotlin-language-server];
              nativeBuildInputs = [pkgs.makeWrapper];
              postBuild = '''
                wrapProgram $out/bin/kotlin-language-server \
                  --prefix PATH : ''${pkgs.kotlin}/bin
              ''';
            };
        '';
        default = pkgs.kotlin-language-server;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Kotlin diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Kotlin";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = diagnosticsToLua {
        lang = "kotlin";
        config = cfg.extraDiagnostics.types;
        inherit diagnosticsProviders;
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.kotlin_language_server = ''
        lspconfig.kotlin_language_server.setup {
          capabilities = capabilities,
          root_dir = lspconfig.util.root_pattern("main.kt", ".git"),
          on_attach=default_on_attach,
          init_options = {
          -- speeds up the startup time for the LSP
            storagePath = vim.fn.stdpath('state') .. '/kotlin',
          },
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/kotlin-language-server"}''
        },
        }
      '';
    })
  ]);
}
