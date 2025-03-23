{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.languages) diagnosticsToLua;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;

  cfg = config.vim.languages.astro;

  defaultServer = "astro";
  servers = {
    astro = {
      package = pkgs.astro-language-server;
      lspConfig = ''
        lspconfig.astro.setup {
          capabilities = capabilities;
          on_attach = attach_keymaps,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/astro-ls", "--stdio"}''
        }
        }
      '';
    };
  };

  # TODO: specify packages
  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.nodePackages.prettier;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.prettier.with({
            command = "${cfg.format.package}/bin/prettier",
          })
        )
      '';
    };

    biome = {
      package = pkgs.biome;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.biome.with({
            command = "${cfg.format.package}/bin/biome",
          })
        )
      '';
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = {
      package = pkgs.eslint_d;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.eslint_d.with({
            command = "${getExe pkg}",
            condition = function(utils)
              return utils.root_has_file({
                "eslint.config.js",
                "eslint.config.mjs",
                ".eslintrc",
                ".eslintrc.json",
                ".eslintrc.js",
                ".eslintrc.yml",
              })
            end,
          })
        )
      '';
    };
  };
in {
  options.vim.languages.astro = {
    enable = mkEnableOption "Astro language support";

    treesitter = {
      enable = mkEnableOption "Astro treesitter" // {default = config.vim.languages.enableTreesitter;};

      astroPackage = mkGrammarOption pkgs "astro";
    };

    lsp = {
      enable = mkEnableOption "Astro LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Astro LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Astro LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.astro-language-server "--minify" "--stdio"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "Astro formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Astro formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Astro formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Astro diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Astro";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.astroPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.astro-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.astro-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = diagnosticsToLua {
        lang = "astro";
        config = cfg.extraDiagnostics.types;
        inherit diagnosticsProviders;
      };
    })
  ]);
}
