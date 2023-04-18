{lib}:
with lib; let
  diagnosticSubmodule = {...}: {
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
    diagnostics,
    defaultDiagnostics,
  }:
    mkOption {
      description = "List of ${langDesc} diagnostics to enable";
      type = with types; listOf (either (enum (attrNames diagnostics)) (submodule diagnosticSubmodule));
      default = defaultDiagnostics;
    };

  mkGrammarOption = pkgs: grammar:
    mkPackageOption pkgs ["${grammar} treesitter"] {
      default = ["vimPlugins" "nvim-treesitter" "builtGrammars" grammar];
    };
}
