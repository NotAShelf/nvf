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

  # helper function to return the desired value based on entry type in lsp server cmd
  pkgOrStr = v:
    if builtins.isString v
    then v
    else lib.getExe v;

  # convert a list of user's LSP args into a list of strings concatenated with commas
  # for example:
  #   ["--foo" "--bar"] -> "--foo", "--bar"
  listArgs = args: builtins.concatStringsSep ", " (map (s: "\"${s}\"") args);
}
