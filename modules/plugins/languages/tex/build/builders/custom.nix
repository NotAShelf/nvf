{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf;
  inherit
    (lib.types)
    bool
    enum
    ints
    listOf
    package
    str
    ;
  inherit
    (builtins)
    attrNames
    concatLists
    concatStringsSep
    elem
    elemAt
    filter
    hasAttr
    isAttrs
    length
    map
    throw
    toString
    ;

  cfg = config.vim.languages.tex;

  # --- Enable Options ---
  mkEnableDefaultOption = default: description: (mkOption {
    type = bool;
    default = default;
    example = !default;
    description = description;
  });

  collateArgs = buildConfig: buildConfig.builders.custom.args;
in {
  options.vim.languages.tex.build.builders.custom = {
    enable = mkEnableDefaultOption false "Whether to enable using a custom build package";
    package = mkOption {
      type = package;
      default = pkgs.tectonic;
      description = "build/compiler package";
    };
    executable = mkOption {
      type = str;
      default = "tectonic";
      description = "The executable name from the build package that will be used to build/compile the tex.";
    };
    args = mkOption {
      type = listOf str;
      default = [
        "-X"
        "compile"
        "%f"
        "--synctex"
        "--keep-logs"
        "--keep-intermediates"
      ];
      description = ''
        Defines additional arguments that are passed to the configured LaTeX build tool.
        Note that flags and their arguments need to be separate elements in this array.
        To pass the arguments -foo bar to a build tool, args needs to be ["-foo" "bar"].
        The placeholder `%f` will be replaced by the server.

        Placeholders:
          - `%f`: The path of the TeX file to compile.
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.build.builders.custom.enable) {
    vim.languages.tex.build.builder = {
      name = "custom";
      args = collateArgs cfg.build;
    };
  };
}
