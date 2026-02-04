{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.scss;

  defaultServer = ["scss-cssls"];
  servers = {
    scss-cssls = {
      cmd = ["${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server" "--stdio"];
      filetypes = ["scss" "sass"];
      # needed to enable formatting
      init_options = {provideFormatter = true;};
      root_markers = [".git" "package.json"];
      settings = {
        scss.validate = true;
      };
    };
  };

  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.prettier;
    };

    prettierd = {
      command = getExe pkgs.prettierd;
    };
  };

  defaultDiagnosticsProvider = ["stylelint"];
  diagnosticsProviders = {
    stylelint = {
      config = {
        cmd = getExe pkgs.stylelint;
      };
    };
  };
in {
  options.vim.languages.scss = {
    enable = mkEnableOption "SCSS/SASS language support";

    treesitter = {
      enable = mkEnableOption "SCSS treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "scss";
    };

    lsp = {
      enable = mkEnableOption "SCSS/SASS LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "SCSS/SASS LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "SCSS/SASS formatting" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        description = "SCSS/SASS formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra SCSS/SASS diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "SCSS";
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

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.scss = cfg.format.type;
          formatters_by_ft.sass = cfg.format.type;
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
        linters_by_ft.scss = cfg.extraDiagnostics.types;
        linters_by_ft.sass = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
