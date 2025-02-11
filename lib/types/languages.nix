{lib}: let
  inherit (lib.options) mkOption mkPackageOption;
  inherit (lib.attrsets) attrNames;
  inherit (lib.types) listOf either enum submodule package bool;

  diagnosticSubmodule = _: {
    options = {
      type = mkOption {
        description = "Type of diagnostic to enable";
        type = attrNames diagnostics;
      };

      package = mkOption {
        type = package;
        description = "Diagnostics package";
      };
    };
  };

  diagnostics = {
    langDesc,
    diagnosticsProviders,
    defaultDiagnosticsProvider,
  }:
    mkOption {
      type = listOf (either (enum (attrNames diagnosticsProviders)) (submodule diagnosticSubmodule));
      default = defaultDiagnosticsProvider;
      description = "List of ${langDesc} diagnostics to enable";
    };

  mkGrammarOption = pkgs: grammar:
    mkPackageOption pkgs ["${grammar} treesitter"] {
      default = ["vimPlugins" "nvim-treesitter" "builtGrammars" grammar];
    };

  mkEnableTreesitterOption = config: language:
    mkOption {
      type = bool;
      default = config.vim.languages.enableTreesitter;
      description = "Whether to enable ${language} treesitter";
    };
in {
  inherit diagnostics diagnosticSubmodule mkGrammarOption mkEnableTreesitterOption;
}
