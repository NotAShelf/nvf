{
  config,
  lib,
  ...
}: let
  inherit (builtins) filter isAttrs hasAttr attrNames length elemAt;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.config) mkBool;
  inherit (lib.options) mkOption;
  inherit (lib.types) str nullOr;

  cfg = config.vim.languages.tex;

  enabledBuildersCount = let
    # This function will sort through the builder options and count how many
    # builders have been enabled.
    getEnabledBuildersCount = {
      enabledBuildersCount ? 0,
      index ? 0,
      builderNamesList ? (
        filter (
          x: let
            y = cfg.build.builders.${x};
          in (isAttrs y && hasAttr "enable" y)
        ) (attrNames cfg.build.builders)
      ),
    }: let
      currentBuilderName = elemAt builderNamesList index;
      currentBuilder = cfg.build.builders.${currentBuilderName};
      nextIndex = index + 1;
      newEnabledBuildersCount =
        if currentBuilder.enable
        then enabledBuildersCount + 1
        else enabledBuildersCount;
    in
      if length builderNamesList > nextIndex
      then
        getEnabledBuildersCount {
          inherit builderNamesList;
          enabledBuildersCount = newEnabledBuildersCount;
          index = nextIndex;
        }
      else newEnabledBuildersCount;
  in (getEnabledBuildersCount {});
in {
  imports = [
    ./builders
  ];

  options.vim.languages.tex.build = {
    enable = mkBool (enabledBuildersCount == 1) ''
      Whether to enable configuring the builder.

      By enabling any of the builders, this option will be automatically set.
      If you enable more than one builder then an error will be thrown.
    '';

    forwardSearchAfter = mkBool false ''
      Set this property to `true` if you want to execute a forward search after
      a build.

      This can also be thought of as enabling auto updating for your pdf viewer.
    '';

    onSave = mkBool false ''
      Set this property to `true` if you want to compile the project after
      saving a file.
    '';

    useFileList = mkBool false ''
      When set to `true`, the server will use the `.fls` files produced by the
      TeX engine as an additional input for the project detection.

      Note that enabling this property might have an impact on performance.
    '';

    auxDirectory = mkOption {
      type = str;
      default = ".";
      description = ''
        When not using latexmk, provides a way to define the directory
        containing the `.aux` files.
        Note that you need to set the aux directory in `latex.build.args` too.

        When using a latexmkrc file, texlab will automatically infer the correct
        setting.
      '';
    };

    logDirectory = mkOption {
      type = str;
      default = ".";
      description = ''
        When not using latexmk, provides a way to define the directory
        containing the build log files.
        Note that you need to change the output directory in your build
        arguments too.

        When using a latexmkrc file, texlab will automatically infer the correct
        setting.
      '';
    };

    pdfDirectory = mkOption {
      type = str;
      default = ".";
      description = ''
        When not using latexmk, provides a way to define the directory
        containing the output files.
        Note that you need to set the output directory in `latex.build.args`
        too.

        When using a latexmkrc file, texlab will automatically infer the correct
        setting.
      '';
    };

    filename = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Allows overriding the default file name of the build artifact.
        This setting is used to find the correct PDF file to open during forward
        search.
      '';
    };
  };

  config = mkIf (enabledBuildersCount > 0) {
    assertions = [
      {
        assertion = enabledBuildersCount < 2;
        message = ''
          The nvf-tex-language implementation does not support having more than
          1 builders enabled.
        '';
      }
    ];
  };
}
