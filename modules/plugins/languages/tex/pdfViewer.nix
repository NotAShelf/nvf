{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) toString;
  inherit (lib) attrNames mkEnableOption mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.types) str package listOf enum;

  cfg = config.vim.languages.tex;

  # **===============================================**
  # ||          <<<<< Default Viewers >>>>>          ||
  # **===============================================**

  viewers = let
    mkPdfViewerDefaults = {
      package,
      executable,
      args ? [],
    }: {
      package = mkDefault package;
      executable = mkDefault executable;
      args = mkDefault args;
    };
  in {
    okular = mkPdfViewerDefaults {
      package = pkgs.kdePackages.okular;
      executable = "okular";
      args = [
        "--unique"
        "file:%p#src:%l%f"
      ];
    };

    sioyek = mkPdfViewerDefaults {
      package = pkgs.sioyek;
      executable = "sioyek";
      args = [
        "--reuse-window"
        "--execute-command"
        "toggle_synctex"
        "--inverse-search"
        "texlab inverse-search -i \"%%1\" -l %%2"
        "--forward-search-file"
        "%f"
        "--forward-search-line"
        "%l"
        "%p"
      ];
    };

    qpdfview = mkPdfViewerDefaults {
      package = pkgs.qpdfview;
      executable = "qpdfview";
      args = [
        "--unique"
        "%p#src:%f:%l:1"
      ];
    };

    zathura = mkPdfViewerDefaults {
      package = pkgs.zathura;
      executable = "zathura";
      args = [
        "--synctex-forward"
        "%l:1:%f"
        "%p"
      ];
    };
  };

  # **====================================================**
  # ||          <<<<< PDF Viewer Submodule >>>>>          ||
  # **====================================================**

  pdfViewer = {name, ...}: {
    options = {
      name = mkOption {
        type = str;
        example = "okular";
        description = ''
          The name of the pdf viewer to use.

          This value will be automatically set when any of the viewers are
          enabled.

          This value will be automatically set to the value of the parent
          attribute set. ex. `...tex.pdfViewer.viewers.<name>.name = "$${name}"`
          This value cannot, and should not, be changed to be different from this
          parent value.

          Default values already exist such as `...tex.pdfViewer.okular` but
          you can override the default values or created completely custom
          pdf viewers should you wish.
        '';
      };

      package = mkOption {
        type = package;
        example = pkgs.kdePackages.okular;
        description = "The package of the pdf viewer to use.";
      };

      executable = mkOption {
        type = str;
        default = "${toString name}";
        description = ''
          The executable for the pdf viewer to use.

          It will be called as `<package_path>/bin/<executable>`.

          By default, the name of the pdf viewer will be used.
        '';
      };

      args = mkOption {
        type = listOf str;
        default = [];
        description = ''
          The command line arguments to use when calling the pdf viewer command.

          These will be called as
          `<package_path>/bin/<executable> <arg1> <arg2> ...`.
        '';
      };
    };

    # The name of the pdf viewer must be set to the parent attribute set name.
    config.name = lib.mkForce name;
  };
in {
  # **==================================================**
  # ||          <<<<< PDF Viewer Options >>>>>          ||
  # **==================================================**

  options.vim.languages.tex.pdfViewer = {
    enable = mkEnableOption "PDF viewer for TeX";

    name = mkOption {
      type = enum (attrNames cfg.pdfViewer.viewers);
      default = "okular";
      description = ''
        The PDF viewer chosen to view compiled TeX documents.

        Must be one of the names of the PDF viewers configured in
        `vim.languages.tex.pdfViewer.viewers`, or one of the default configured
        viewers: ${concatStringsSep ", " (attrNames cfg.pdfViewer.viewers)}.
      '';
    };

    viewers = mkOption {
      type = with lib.types; attrsOf (submodule pdfViewer);
      default = {};
      example = {
        customOkular = {
          package = pkgs.kdePackages.okular;
          executable = "okular";
          args = [
            "--unique"
            "file:%p#src:%l%f"
          ];
        };
      };
      description = ''
        Define the PDF viewers that can be used for viewing compiled tex documents.
      '';
    };
  };

  # Set the default pdf viewers.
  config.vim.languages.tex.pdfViewer.viewers = viewers;
}
