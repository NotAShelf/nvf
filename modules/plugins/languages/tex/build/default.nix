{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool str;

  cfg = config.vim.languages.tex;
in {
  imports = [
    ./builders
  ];

  options.vim.languages.tex.build = {
    forwardSearchAfter = mkOption {
      type = bool;
      default = false;
      description = "Set this property to true if you want to execute a forward search after a build.";
    };
    onSave = mkOption {
      type = bool;
      default = false;
      description = "Set this property to true if you want to compile the project after saving a file.";
    };
    useFileList = mkOption {
      type = bool;
      default = false;
      description = ''
        When set to true, the server will use the .fls files produced by the TeX engine as an additional input for the project detection.

        Note that enabling this property might have an impact on performance.
      '';
    };
    auxDirectory = mkOption {
      type = str;
      default = ".";
      description = ''
        When not using latexmk, provides a way to define the directory containing the .aux files.
        Note that you need to set the aux directory in latex.build.args too.

        When using a latexmkrc file, texlab will automatically infer the correct setting.
      '';
    };
    logDirectory = mkOption {
      type = str;
      default = ".";
      description = ''
        When not using latexmk, provides a way to define the directory containing the build log files.
        Note that you need to change the output directory in your build arguments too.

        When using a latexmkrc file, texlab will automatically infer the correct setting.
      '';
    };
    pdfDirectory = mkOption {
      type = str;
      default = ".";
      description = ''
        When not using latexmk, provides a way to define the directory containing the output files.
        Note that you need to set the output directory in latex.build.args too.

        When using a latexmkrc file, texlab will automatically infer the correct setting.
      '';
    };
    filename = mkOption {
      type = str;
      default = "";
      description = ''
        Allows overriding the default file name of the build artifact. This setting is used to find the correct PDF file to open during forward search.
      '';
    };
  };
}
