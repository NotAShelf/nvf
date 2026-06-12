{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum coercedTo listOf;
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.svelte;

  defaultServers = ["svelte-language-server"];
  servers = ["svelte-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = let
    prettierPlugin = inputs.self.packages.${pkgs.stdenv.system}.prettier-plugin-svelte;
    prettierPluginPath = "${prettierPlugin}/lib/node_modules/prettier-plugin-svelte/plugin.js";
  in {
    prettier = {
      command = getExe pkgs.prettier;
      options.ft_parsers.svelte = "svelte";
      prepend_args = ["--plugin=${prettierPluginPath}"];
    };

    biome = {
      command = getExe pkgs.biome;
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = let
      pkg = pkgs.eslint_d;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
        required_files = [
          "eslint.config.js"
          "eslint.config.mjs"
          ".eslintrc"
          ".eslintrc.json"
          ".eslintrc.js"
          ".eslintrc.yml"
        ];
      };
    };
  };

  formatType =
    deprecatedSingleOrListOf
    "vim.languages.svelte.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.svelte.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum (attrNames formats)));
in {
  options.vim.languages.svelte = {
    enable = mkEnableOption "Svelte language support";

    treesitter = {
      enable =
        mkEnableOption "Svelte treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      sveltePackage = mkGrammarOption pkgs "svelte";
    };

    lsp = {
      enable =
        mkEnableOption "Svelte LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Svelte LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Svelte formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = formatType;
        default = defaultFormat;
        description = "Svelte formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Svelte diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = diagnostics {
        langDesc = "Svelte";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.sveltePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["svelte"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.svelte = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.svelte = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
