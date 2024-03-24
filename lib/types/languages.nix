{lib}:
with lib; let
  diagnosticSubmodule = _: {
    options = {
      type = mkOption {
        description = "Type of diagnostic to enable";
        type = attrNames diagnostics;
      };
      package = mkOption {
        description = "Diagnostics package";
        type = types.package;
      };
    };
  };
in {
  diagnostics = {
    langDesc,
    diagnosticsProviders,
    defaultDiagnosticsProvider,
  }:
    mkOption {
      description = "List of ${langDesc} diagnostics to enable";
      type = with types; listOf (either (enum (attrNames diagnosticsProviders)) (submodule diagnosticSubmodule));
      default = defaultDiagnosticsProvider;
    };

  mkGrammarOption = pkgs: grammar:
    mkPackageOption pkgs ["${grammar} treesitter"] {
      default = ["vimPlugins" "nvim-treesitter" "builtGrammars" grammar];
    };
}
