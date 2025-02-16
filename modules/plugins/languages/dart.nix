{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum either listOf package str bool;
  inherit (lib.lists) isList;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.dart;
  ftcfg = cfg.flutter-tools;

  defaultServer = "dart";
  servers = {
    dart = {
      package = pkgs.dart;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["dart"];
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${getExe cfg.lsp.package}" "language-server" "--protocol=lsp"];
        single_file_support = true;
        init_options = {
          closingLabels = true;
          flutterOutline = true;
          onlyAnalyzeProjectsWithOpenFiles = true;
          outline = true;
          suggestFromUnimportedLibraries = true;
        };
        settings = {
          dart = {
            completeFunctionCalls = true;
            showTodos = true;
          };
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

      options = mkOption {
        type = lspOptions;
        default = servers.${cfg.lsp.server}.options;
        description = ''
          LSP options for Dart language support.

          This option is freeform, you may add options that are not set by default
          and they will be merged into the final table passed to lspconfig.
        '';
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
        default = config.vim.languages.enableLSP;
        description = "Enable flutter-tools for flutter support";
      };

      enableNoResolvePatch = mkOption {
        type = bool;
        default = true;
        description = ''
          Whether to patch flutter-tools so that it doesn't resolve
          symlinks when detecting flutter path.

          This is required if you want to use a flutter package built with nix.
          If you are using a flutter SDK installed from a different source
          and encounter the error "`dart` missing from PATH", disable this option.
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
      vim.lsp.lspconfig = {
        enable = true;
        sources.dart-lsp = ''
          lspconfig.${toLuaObject cfg.lsp.server}.setup(${toLuaObject cfg.lsp.options})
        '';
      };
    })

    (mkIf ftcfg.enable {
      vim.startPlugins =
        if ftcfg.enableNoResolvePatch
        then ["flutter-tools-patched"]
        else ["flutter-tools-nvim"];

      vim.pluginRC.flutter-tools = entryAnywhere ''
        require('flutter-tools').setup {
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
            flags = lsp_flags,
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
