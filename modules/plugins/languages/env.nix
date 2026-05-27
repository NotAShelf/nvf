{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption literalExpression;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) diagnostics;

  cfg = config.vim.languages.env;

  defaultDiagnosticsProvider = ["dotenv-linter"];
  diagnosticsProviders = {
    dotenv-linter = let
      pkg = pkgs.dotenv-linter;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
      };
    };
  };
in {
  options.vim.languages.env = {
    enable = mkEnableOption "Env language support";

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Env diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = diagnostics {
        langDesc = "Env";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
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
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.env = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
