{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.types) listOf enum;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.make;

  defaultFormat = ["bake"];
  formats = {
    bake = {
      command = "${pkgs.mbake}/bin/mbake";
    };
  };

  defaultDiagnosticsProvider = ["checkmake"];
  diagnosticsProviders = {
    checkmake = {
      config = {
        cmd = getExe pkgs.checkmake;
      };
    };
  };
in {
  options.vim.languages.make = {
    enable = mkEnableOption "Make support";

    treesitter = {
      enable = mkEnableOption "Make treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "make";
    };

    format = {
      enable = mkEnableOption "Make formatting" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        description = "make formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Make diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "Make";
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

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.make = cfg.format.type;
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
        linters_by_ft.make = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
