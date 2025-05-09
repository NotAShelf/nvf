{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.trivial) boolToString;
  inherit (lib.lists) isList;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum either listOf package nullOr str bool;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.dart;
  ftcfg = cfg.flutter-tools;

  defaultServer = "dart";
  servers = {
    dart = {
      package = pkgs.dart;
      lspConfig = ''
        lspconfig.dartls.setup{
          capabilities = capabilities;
          on_attach=default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/dart", "language-server", "--protocol=lsp"}''
        };
          ${optionalString (cfg.lsp.opts != null) "init_options = ${cfg.lsp.dartOpts}"}
        }
      '';
    };
  };
in {
  options.vim.languages.dart = {
    enable = mkEnableOption "Dart language support";

    treesitter = {
      enable = mkEnableOption "Dart treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "dart";
    };

    lsp = {
      enable = mkEnableOption "Dart LSP support";
      server = mkOption {
        description = "The Dart LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        description = "Dart LSP server package, or the command to run as a list of strings";
      };

      opts = mkOption {
        type = nullOr str;
        default = null;
        description = "Options to pass to Dart LSP server";
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable Dart DAP support via flutter-tools";
        type = bool;
        default = config.vim.languages.enableDAP;
      };
    };

    flutter-tools = {
      enable = mkOption {
        type = bool;
        default = config.vim.lsp.enable;
        description = "Enable flutter-tools for flutter support";
      };

      flutterPackage = mkOption {
        type = nullOr package;
        default = pkgs.flutter;
        description = "Flutter package, or null to detect the flutter path at runtime instead.";
      };

      enableNoResolvePatch = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to patch flutter-tools so that it doesn't resolve
          symlinks when detecting flutter path.

          ::: {.note}
          This is required if `flutterPackage` is set to null and the flutter
          package in your `PATH` was built with Nix. If you are using a flutter
          SDK installed from a different source and encounter the error "`dart`
          missing from `PATH`", leave this option disabled.
          :::
        '';
      };

      color = {
        enable = mkEnableOption "highlighting color variables";

        highlightBackground = mkOption {
          type = bool;
          default = false;
          description = "Highlight the background";
        };

        highlightForeground = mkOption {
          type = bool;
          default = false;
          description = "Highlight the foreground";
        };

        virtualText = {
          enable = mkEnableOption "Show the highlight using virtual text";

          character = mkOption {
            type = str;
            default = "■";
            description = "Virtual text character to highlight";
          };
        };
      };
    };
  };

  config.vim = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      treesitter.enable = true;
      treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      lsp.lspconfig.enable = true;
      lsp.lspconfig.sources.dart-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf ftcfg.enable {
      startPlugins = [
        (
          if ftcfg.enableNoResolvePatch
          then "flutter-tools-patched"
          else "flutter-tools-nvim"
        )
        "plenary-nvim"
      ];

      pluginRC.flutter-tools = entryAfter ["lsp-setup"] ''
        require('flutter-tools').setup {
          ${optionalString (ftcfg.flutterPackage != null) "flutter_path = \"${ftcfg.flutterPackage}/bin/flutter\","}
          lsp = {
            color = { -- show the derived colours for dart variables
              enabled = ${boolToString ftcfg.color.enable}, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
              background = ${boolToString ftcfg.color.highlightBackground}, -- highlight the background
              foreground = ${boolToString ftcfg.color.highlightForeground}, -- highlight the foreground
              virtual_text = ${boolToString ftcfg.color.virtualText.enable}, -- show the highlight using virtual text
              virtual_text_str = ${ftcfg.color.virtualText.character} -- the virtual text character to highlight
            },

            capabilities = capabilities,
            on_attach = default_on_attach;
          },
          ${optionalString cfg.dap.enable ''
          debugger = {
            enabled = true,
          },
        ''}
        }
      '';
    })
  ]);
}
