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
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;

  cfg = config.vim.languages.astro;

  defaultServer = "astro";
  servers = {
    astro = {
      package = pkgs.astro-language-server;
      lspConfig = ''
        lspconfig.astro.setup {
          capabilities = capabilities,
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
    };

    prettierd = {
      package = pkgs.prettierd;
    };

    biome = {
      package = pkgs.biome;
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = {
      package = pkgs.eslint_d;
      config = {
        # HACK: change if nvim-lint gets a dynamic enable thing
        parser = mkLuaInline ''
          function(output, bufnr, cwd)
            local markers = { "eslint.config.js", "eslint.config.mjs",
              ".eslintrc", ".eslintrc.json", ".eslintrc.js", ".eslintrc.yml", }
            for _, filename in ipairs(markers) do
              local path = vim.fs.joinpath(cwd, filename)
              if vim.loop.fs_stat(path) then
                return require("lint.linters.eslint_d").parser(output, bufnr, cwd)
              end
            end

            return {}
          end
        '';
      };
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
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Astro LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.astro-language-server "--minify" "--stdio"]'';
        description = "Astro LSP server package, or the command to run as a list of strings";
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
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.astro = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.astro = cfg.extraDiagnostics.types;
        linters = mkMerge (map (
            name: {
              ${name} =
                diagnosticsProviders.${name}.config
                // {
                  cmd = getExe diagnosticsProviders.${name}.package;
                };
            }
          )
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
