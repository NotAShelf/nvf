{
  config,
  lib,
  pkgs,
  ...
}: let
  defaultPdfViewerName = "okular";

  inherit (lib) mkOverride;
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) str package listOf;
  inherit (builtins) filter isAttrs hasAttr attrNames length elemAt;
  inherit (lib.nvim.config) mkBool;

  cfg = config.vim.languages.tex;
  viewersCfg = cfg.pdfViewer.viewers;

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
            y = viewersCfg.${x};
          in (
            isAttrs y
            && hasAttr "enable" y
            && hasAttr "package" y
            && hasAttr "executable" y
            && hasAttr "args" y
          )
        ) (attrNames viewersCfg)
      ),
      currentEnabledPdfViewerName ? defaultPdfViewerName,
    }: let
      # Get the name of the current pdf viewer being checked if it is enabled
      currentPdfViewerName = elemAt pdfViewerNamesList index;

      # Get the current pdf viewer object
      currentPdfViewer = viewersCfg.${currentPdfViewerName};

      # Get the index that will be used for the next iteration
      nextIndex = index + 1;

      # Increment the count that is recording the number of enabled pdf viewers if
      # this viewer is enabled, otherwise leave it as is.
      newEnabledPdfViewersCount =
        if currentPdfViewer.enable
        then enabledPdfViewersCount + 1
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

  enabledPdfViewerCfg = viewersCfg.${enabledPdfViewersInfo.enabledViewerName};

in {
  imports = [
    ./viewers
  ];

  options.vim.languages.tex.pdfViewer = {
    enable =
      mkBool (
        if enabledPdfViewersInfo.count > 1
        then throw "nvf-tex-language does not support having more than 1 pdf viewer enabled!"
        else (enabledPdfViewersInfo.count == 1)
      ) ''
        Whether to enable configuring the pdf viewer.

        By enabling any of the pdfViewers, this option will be automatically set.
        If you enable more than one pdf viewer then an error will be thrown.
      '';

    name = mkOption {
      type = str;
      default = enabledPdfViewerCfg.name;
      description = ''
        TODO
      '';
    };

    package = mkOption {
      type = package;
      default = enabledPdfViewerCfg.package;
      description = ''
        The package to set to use a custom viewer.
      '';
    };

    executable = mkOption {
      type = str;
      default = enabledPdfViewerCfg.executable;
      description = ''
        TODO
      '';
    };

    args = mkOption {
      type = listOf str;
      default = enabledPdfViewerCfg.args;
      description = ''
        TODO
      '';
    };
  };

  # If the pdf viewer has been enabled, but none of the individual viewers have been enabled,
  # then enable the default viewer.
  config = mkIf (cfg.enable && cfg.pdfViewer.enable && enabledPdfViewersInfo.count == 0) {
    vim.languages.tex.pdfViewer.viewers.${defaultPdfViewerName}.enable = mkOverride 75 true;
  };
}
