{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) str package listOf;

  cfg = config.vim.languages.tex;

  pdfViewer = {name, ...}: {
    options = {
      enable = lib.mkEnableOption "${builtins.toString name} pdf viewer";

      name = mkOption {
        type = str;
        example = "okular";
        description = ''
          The name of the pdf viewer to use.

          This value will be automatically set when any of the viewers are
          enabled.

          This value will be automatically set to the value of the parent
          attribute set. ex. `...tex.pdfViewer.<name>.name = "$${name}"`
          This value cannot and should not be changed to be different from this
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
        default = "${builtins.toString name}";
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
  imports = [
    ./premadePdfViewers.nix
  ];

  options.vim.languages.tex.pdfViewer = mkOption {
    type = with lib.types; attrsOf (submodule pdfViewer);
    default = {};
    example = {
      zathura.enable = true;

      customOkular = {
        enable = false;
        package = pkgs.kdePackages.okular;
        executable = "okular";
        args = [
          "--unique"
          "file:%p#src:%l%f"
        ];
      };
    };
  };

  config = let
    # List form of all pdf viewers.
    pdfViewers = builtins.attrValues cfg.pdfViewer;

    countPdfViewers = viewers: (lib.lists.count (x: x.enable) viewers);
  in {
    assertions = [
      {
        # Assert that there is only one enabled pdf viewer.
        assertion = (countPdfViewers pdfViewers) < 2;
        message = ''
          The nvf-tex-language implementation does not support having more than
          1 pdf viewers enabled.
        '';
      }
    ];
  };
}
