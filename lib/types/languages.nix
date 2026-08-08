{lib}: let
  inherit (lib.options) mkPackageOption;

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

  mkCustomGrammarOption = inputs: pkgs: grammar:
    mkPackageOption inputs.self.packages.${pkgs.stdenv.hostPlatform.system} ["${grammar} treesitter"] {
      default = ["tree-sitter-${grammar}"];
      nullable = true;
    };
in {
  inherit mkGrammarOption mkTreesitterGrammarOption mkCustomGrammarOption;
}
