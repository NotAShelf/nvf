{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames elem;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum bool listOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption diagnostics mkPluginSetupOption enumWithRename;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.typescript;

  defaultServers = ["typescript-language-server"];
  servers = ["typescript-language-server" "deno" "typescript-go" "angular-language-server" "emmet-ls"];

  # TODO: specify packages
  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.prettier;
    };

    prettierd = {
      command = getExe pkgs.prettierd;
    };

    biome = {
      command = getExe pkgs.biome;
    };

    biome-check = {
      command = getExe pkgs.biome;
    };

    biome-organize-imports = {
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
          ".eslintrc.cjs"
          ".eslintrc.json"
          ".eslintrc.js"
          ".eslintrc.yml"
        ];
      };
    };
    biomejs = let
      pkg = pkgs.biome;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
      };
    };
  };
in {
  options.vim.languages.typescript = {
    enable = mkEnableOption "Typescript/Javascript language support";

    treesitter = {
      enable =
        mkEnableOption "Typescript/Javascript treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      tsPackage = mkGrammarOption pkgs "typescript";
      jsPackage = mkGrammarOption pkgs "javascript";
    };

    lsp = {
      enable =
        mkEnableOption "Typescript/Javascript LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.ts.lsp.servers"
          servers
          {
            ts_ls = "typescript-language-server";
            denols = "deno";
            tsgo = "typescript-go";
          });
        default = defaultServers;
        description = "Typescript/Javascript LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Typescript/Javascript formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Typescript/Javascript formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Typescript/Javascript diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Typescript/Javascript";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };

    extensions = {
      ts-error-translator = {
        enable = mkEnableOption ''
          [ts-error-translator.nvim]: https://github.com/dmmulroy/ts-error-translator.nvim

          Typescript error translation with [ts-error-translator.nvim]

        '';

        setupOpts = mkPluginSetupOption "ts-error-translator" {
          # This is the default configuration behaviour.
          auto_override_publish_diagnostics = mkOption {
            description = "Automatically override the publish_diagnostics handler";
            type = bool;
            default = true;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.tsPackage
        cfg.treesitter.jsPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "typescript"
            # TODO: move to a JavaScript module
            "javascript"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            typescript = cfg.format.type;
            javascript = cfg.format.type;
          };
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
        linters_by_ft.typescript = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })

    # Extensions
    (mkIf cfg.extensions."ts-error-translator".enable {
      vim.startPlugins = ["ts-error-translator-nvim"];
      vim.pluginRC.ts-error-translator = entryAnywhere ''
        require("ts-error-translator").setup(${toLuaObject cfg.extensions.ts-error-translator.setupOpts})
      '';
    })

    # Warn the user if they have set the default server name to "tsserver" to match upstream (us)
    # The name "tsserver" has been deprecated, and now should be called "typescript-language-server".
    {
      assertions = [
        {
          assertion = cfg.lsp.enable -> !(elem "tsserver" cfg.lsp.servers);
          message = ''
            The name `tsserver` has been deprecated, and now should be called `typescript-language-server`.
            Please set `vim.languages.ts.lsp.server` to `["typescript-language-server" ...]` instead of to `["tsserver" ...]`

            Please see:
            - <https://github.com/neovim/nvim-lspconfig/pull/3232>
            - <https://github.com/NotAShelf/nvf/pull/1514>
            for more details about this change.
          '';
        }
      ];
    }
  ]);
}
