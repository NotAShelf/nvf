{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib.attrsets) attrNames genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;

  cfg = config.vim.languages.tsx;

  defaultServers = ["typescript-language-server"];
  servers = ["typescript-language-server" "deno" "typescript-go" "emmet-ls"];

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

  defaultDiagnosticsProvider = ["biomejs"];
  diagnosticsProviders = {
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
  options.vim.languages.tsx = {
    enable = mkEnableOption "Typescript XML (TSX) language support";

    treesitter = {
      enable =
        mkEnableOption "Typescript XML (TSX) treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "tsx";
    };

    lsp = {
      enable =
        mkEnableOption "Typescript XML (TSX) LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Typescript XML (TSX) LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Typescript XML (TSX) formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Typescript XML (TSX) formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Typescript XML (TSX) diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Typescript XML (TSX)";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "typescriptreact"
            "javascriptreact"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            typescriptreact = cfg.format.type;
            javascriptreact = cfg.format.type;
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
        linters_by_ft = {
          typescriptreact = cfg.extraDiagnostics.types;
          javascriptreact = cfg.extraDiagnostics.types;
        };
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
