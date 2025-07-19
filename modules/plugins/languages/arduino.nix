{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.strings) concatMapStrings optionalString;
  inherit (lib.types) listOf nullOr package str;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.arduino;
in {
  options.vim.languages.arduino = {
    enable = mkEnableOption "Arduino support";

    treesitter = {
      enable = mkEnableOption "Arduino treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "arduino";
    };

    lsp = {
      enable = mkEnableOption "Arduino LSP support (arduino-language-server)" // {default = config.vim.lsp.enable;};

      package = mkOption {
        type = package;
        default = pkgs.arduino-language-server;
        description = "arduino-language-server package";
      };

      clangdPackage = mkOption {
        type = package;
        default = config.vim.languages.clang.lsp.package;
        description = "clangd package";
      };

      arduinoCliPackage = mkOption {
        type = package;
        default = pkgs.arduino-cli;
        description = "arduino-cli package";
      };

      configPath = mkOption {
        type = str;
        default = "$HOME/.arduino15/arduino-cli.yaml";
        description = "Path to the arduino-cli config";
      };

      fqbn = mkOption {
        type = nullOr str;
        default = null;
        description = "Fully Qualified Board Name";
      };

      extraArgs = mkOption {
        type = listOf str;
        default = [];
        description = "Extra arguments passed to arduino-language-server";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.arduino-language-server = ''
        lspconfig.arduino_language_server.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {
            "${getExe cfg.lsp.package}",
            "-clangd", "${getExe' cfg.lsp.clangdPackage "clangd"}",
            "-cli", "${getExe cfg.lsp.arduinoCliPackage}",
            "-cli-config", "${cfg.lsp.configPath}"
            ${optionalString (cfg.lsp.fqbn != null)
          '', "-fqbn", "${cfg.lsp.fqbn}"''}
            ${optionalString (cfg.lsp.extraArgs != [])
          (concatMapStrings (arg: '', "${arg}"'') cfg.lsp.extraArgs)}
          },
        }
      '';
    })
  ]);
}
