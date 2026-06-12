{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption literalExpression mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.types) enum listOf;

  cfg = config.vim.languages.env;

  defaultDiagnosticsProvider = ["dotenv-linter"];
  diagnosticsProviders = ["dotenv-linter"];
in {
  options.vim.languages.env = {
    enable = mkEnableOption "Env language support";

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Env diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostic";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Env diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.autocmds = [
        {
          event = ["BufRead" "BufNewFile"];
          pattern = [
            # support common names like `dist.env`
            "*.env"
            # support weird env files names like symfony ones.
            ".env.*"
          ];
          command = "set filetype=env";
        }
      ];
    }

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.env = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
