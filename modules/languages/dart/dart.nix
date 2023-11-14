{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) isList nvim mkEnableOption mkOption types optionalString;

  cfg = config.vim.languages.dart;
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
          then nvim.lua.expToLua cfg.lsp.package
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
      package = nvim.types.mkGrammarOption pkgs "dart";
    };

    lsp = {
      enable = mkEnableOption "Dart LSP support";
      server = mkOption {
        description = "The Dart LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Dart LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
      opts = mkOption {
        description = "Options to pass to Dart LSP server";
        type = with types; nullOr str;
        default = null;
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable Dart DAP support via flutter-tools";
        type = types.bool;
        default = config.vim.languages.enableDAP;
      };
    };

    flutter-tools = {
      enable = mkOption {
        description = "Enable flutter-tools for flutter support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };

      enableNoResolvePatch = mkOption {
        description = ''
          Patch flutter-tools so that it doesn't resolve symlinks when detecting flutter path.
          This is required if you want to use a flutter package built with nix.
          If you are using a flutter SDK installed from a different source and encounter the error "`dart` missing from PATH", disable this option.
        '';
        type = types.bool;
        default = true;
      };

      color = {
        enable = mkEnableOption "Whether or mot to highlight color variables at all";

        highlightBackground = mkOption {
          type = types.bool;
          default = false;
          description = "Highlight the background";
        };

        highlightForeground = mkOption {
          type = types.bool;
          default = false;
          description = "Highlight the foreground";
        };

        virtualText = {
          enable = mkEnableOption "Show the highlight using virtual text";

          character = mkOption {
            type = types.str;
            default = "■";
            description = "Virtual text character to highlight";
          };
        };
      };
    };
  };
}
