{
  config,
  lib,
  ...
}: let
  defaultPdfViewerName = "okular";

  inherit (lib.options) mkOption;
  inherit (lib.types) str package listOf;
  inherit (builtins) filter isAttrs hasAttr attrNames length elemAt;

  cfg = config.vim.languages.tex;
  viewerCfg = cfg.pdfViewer;

  enabledPdfViewersInfo = let
    # This function will sort through the pdf viewer options and count how many
    # pdf viewers have been enabled.
    # If no viewers have been enabled, the count will be 0 and the name of the
    # enabled viewer will be the default pdf viewer defined above.
    getEnabledPdfViewersInfo = {
      enabledPdfViewersCount ? 0,
      index ? 0,
      pdfViewerNamesList ? (
        filter (
          x: let
            y = viewerCfg.${x};
          in (
            isAttrs y
            && hasAttr "enable" y
            && hasAttr "package" y
            && hasAttr "executable" y
            && hasAttr "args" y
          )
        ) (attrNames viewerCfg)
      ),
      currentEnabledPdfViewerName ? defaultPdfViewerName,
    }: let
      # Get the name of the current pdf viewer being checked if it is enabled
      currentPdfViewerName = elemAt pdfViewerNamesList index;

      # Get the current pdf viewer object
      currentPdfViewer = viewerCfg.${currentPdfViewerName};

      # Get the index that will be used for the next iteration
      nextIndex = index + 1;

      # Increment the count that is recording the number of enabled pdf viewers if
      # this viewer is enabled, otherwise leave it as is.
      newEnabledPdfViewersCount =
        if currentPdfViewer.enable
        then
          if enabledPdfViewersCount > 0
          then throw "nvf-tex-language does not support having more than 1 pdf viewer enabled!"
          else enabledPdfViewersCount + 1
        else enabledPdfViewersCount;

      # If this pdf viewer is enabled, set is as the enabled viewer.
      newEnabledPdfViewerName =
        if currentPdfViewer.enable
        then currentPdfViewerName
        else currentEnabledPdfViewerName;
    in
      # Check that the end of the list of viewers has not been reached
      if length pdfViewerNamesList > nextIndex
      # If the end of the viewers list has not been reached, call the next iteration
      # of the function to process the next viewer
      then
        getEnabledPdfViewersInfo {
          inherit pdfViewerNamesList;
          enabledPdfViewersCount = newEnabledPdfViewersCount;
          index = nextIndex;
          currentEnabledPdfViewerName = newEnabledPdfViewerName;
        }
      # If the end of the viewers list has been reached, then return the total number
      # of viewers that have been enabled and the name of the last viewer that was enabled.
      else {
        count = newEnabledPdfViewersCount;
        enabledViewerName = newEnabledPdfViewerName;
      };
  in (getEnabledPdfViewersInfo {});

  enabledPdfViewerCfg = viewerCfg.${enabledPdfViewersInfo.enabledViewerName};
in {
  imports = [
    ./custom.nix
    ./okular.nix
    ./sioyek.nix
    ./qpdfview.nix
    ./zathura.nix
  ];

  options.vim.languages.tex.pdfViewer = {
    name = mkOption {
      type = str;
      default = enabledPdfViewerCfg.name;
      description = ''
        The name of the pdf viewer to use.

        This value will be automatically set when any of the viewers are enabled.

        Setting this option option manually is not recommended but can be used for some very technical nix-ing.
        If you wish to use a custom viewer, please use the `custom` entry provided under `viewers`.
      '';
    };

    package = mkOption {
      type = package;
      default = enabledPdfViewerCfg.package;
      description = ''
        The package of the pdf viewer to use.

        This value will be automatically set when any of the viewers are enabled.

        Setting this option option manually is not recommended but can be used for some very technical nix-ing.
        If you wish to use a custom viewer, please use the `custom` entry provided under `viewers`.
      '';
    };

    executable = mkOption {
      type = str;
      default = enabledPdfViewerCfg.executable;
      description = ''
        The executable for the pdf viewer to use.

        This value will be automatically set when any of the viewers are enabled.

        Setting this option option manually is not recommended but can be used for some very technical nix-ing.
        If you wish to use a custom viewer, please use the `custom` entry provided under `viewers`.
      '';
    };

    args = mkOption {
      type = listOf str;
      default = enabledPdfViewerCfg.args;
      description = ''
        The command line arguments to use when calling the pdf viewer command.

        This value will be automatically set when any of the viewers are enabled.

        Setting this option option manually is not recommended but can be used for some very technical nix-ing.
        If you wish to use a custom viewer, please use the `custom` entry provided under `viewers`.
      '';
    };
  };
}
