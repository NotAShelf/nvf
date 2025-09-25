{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.trivial) boolToString;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum package nullOr str bool;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.dart;
  ftcfg = cfg.flutter-tools;

  defaultServers = ["dart"];
  servers = {
    dart = {
      enable = true;
      cmd = [(getExe pkgs.dart) "language-server" "--protocol=lsp"];
      filetypes = ["dart"];
      root_markers = ["pubspec.yaml"];
      init_options = {
        onlyAnalyzeProjectsWithOpenFiles = true;
        suggestFromUnimportedLibraries = true;
        closingLabels = true;
        outline = true;
        flutterOutline = true;
      };
      settings = {
        dart = {
          completeFunctionCalls = true;
          showTodos = true;
        };
      };
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
      enable = mkEnableOption "Dart LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Dart LSP server to use";
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

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
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
