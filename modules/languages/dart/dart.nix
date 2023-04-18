{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.dart;
  defaultServer = "dart";
  servers = {
    dart = {
      package = pkgs.dart;
      lspConfig = ''
        lspconfig.dartls.setup{
          capabilities = capabilities;
          on_attach=default_on_attach;
          cmd = {"${pkgs.dart}/bin/dart", "language-server", "--protocol=lsp"};
          ${optionalString (cfg.lsp.opts != null) "init_options = ${cfg.lsp.dartOpts}"}
        }
      '';
    };
  };
in {
  options.vim.languages.dart = {
    enable = mkEnableOption "Dart language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Dart treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "dart";
    };

    lsp = {
      enable = mkEnableOption "Enable Dart LSP support";
      server = mkOption {
        description = "The Dart LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Dart LSP server package";
        type = types.package;
        default = servers.${cfg.lsp.server}.package;
      };
      opts = mkOption {
        description = "Options to pass to Dart LSP server";
        type = with types; nullOr str;
        default = null;
      };
    };

    flutter-tools = {
      enable = mkOption {
        description = "Enable flutter-tools for flutter support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
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
