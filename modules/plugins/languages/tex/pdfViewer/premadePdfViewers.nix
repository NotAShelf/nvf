{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkForce;

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
  config.vim.languages.tex.pdfViewer = {
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

    # This is a special pdf viewer. It is force set to a basic and known
    # working configuration of okular and is used where needed in the
    # rest of the tex language configuration encase no other pdf viewer
    # was enabled.
    # It cannot be enabled on its own and exists purely as a fallback
    # option for internal use.
    fallback = {
      enable = mkForce false;
      package = mkForce pkgs.kdePackages.okular;
      executable = mkForce "okular";
      args = mkForce [
        "--unique"
        "file:%p#src:%l%f"
      ];
    };
  };
}
