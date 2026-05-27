{lib}: let
  inherit (lib.options) mkOption mkPackageOption;
  inherit (lib.attrsets) attrNames;
  inherit (lib.types) listOf either enum submodule package;

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
      default = ["vimPlugins" "nvim-treesitter" "grammarPlugins" grammar];
      nullable = true;
    };

  # Prefer using `mkGrammarOption` and only use this, for grammars,
  # not in `vimPlugins.nvim-treesitter.grammarPlugins`.
  # Grammars from `tree-sitter-grammars.tree-sitter-<name>` should mostly
  # just work, but should be tested extra, as we currently only use them
  # for a small subset of language modules.
  mkTreesitterGrammarOption = pkgs: grammar:
    mkPackageOption pkgs ["${grammar} treesitter"] {
      default = ["tree-sitter-grammars" "tree-sitter-${grammar}"];
      nullable = true;
    };
in {
  inherit diagnostics diagnosticSubmodule mkGrammarOption mkTreesitterGrammarOption;
}
