{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum nullOr str bool listOf;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.languages.dart;
  ftcfg = cfg.extensions.flutter-tools;

  defaultServers = ["dart"];
  servers = ["dart"];
in {
  options.vim.languages.dart = {
    enable = mkEnableOption "Dart language support";

    treesitter = {
      enable =
        mkEnableOption "Dart treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "dart";
    };

    lsp = {
      enable =
        mkEnableOption "Dart LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Dart LSP server to use";
      };
    };

    dap = {
      enable =
        mkEnableOption "Dart DAP support via flutter-tools"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };
    };

    extensions = {
      flutter-tools = {
        enable =
          mkEnableOption "flutter-tools for flutter support"
          // {
            default = config.vim.lsp.enable;
            defaultText = literalExpression "config.vim.lsp.enable";
          };

        enableNoResolvePatch = mkOption {
          type = bool;
          default = false;
          description = ''
            Whether to patch flutter-tools so that it doesn't resolve
            symlinks when detecting flutter path.

            ::: {.note}
            This is required if `setupOpts.flutter-tools` is set to null and the flutter
            package in your `PATH` was built with Nix. If you are using a flutter
            SDK installed from a different source and encounter the error "`dart`
            missing from `PATH`", leave this option disabled.
            :::
          '';
        };

        setupOpts = mkPluginSetupOption "flutter-tools" {
          flutter_path = mkOption {
            type = nullOr str;
            default = getExe pkgs.flutter;
            description = "Path to flutter binary to use";
          };

          debugger = {
            enabled = mkEnableOption "Whether to enable the debugger";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["dart"];
        });
      };
    })

    (mkIf cfg.dap.enable {
      vim.languages.dart.extensions.flutter-tools = {
        enable = true;
        setupOpts.debugger.enabled = true;
      };
    })

    (mkIf ftcfg.enable {
      vim.startPlugins = [
        (
          if ftcfg.enableNoResolvePatch
          then "flutter-tools-patched"
          else "flutter-tools-nvim"
        )
        "plenary-nvim"
      ];

      vim.pluginRC.flutter-tools = entryAfter ["lsp-servers"] ''
        require('flutter-tools').setup(${toLuaObject ftcfg.setupOpts})
      '';
    })
  ]);
}
