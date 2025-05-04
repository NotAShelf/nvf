{
  config,
  lib,
  ...
}: let
  # The attribute set of pdf viewers in this configuration.
  pdfViewers = config.vim.languages.tex.pdfViewer;

  # The list of pdf viewers in this configuration.
  pdfViewersList = builtins.attrValues pdfViewers;

  # The list of enabled pdf viewers.
  enabledPdfViewersList = builtins.filter (x: x.enable) pdfViewersList;

  # The number of enabled pdf viewers.
  enabledPdfViewersCount = lib.lists.count (x: x.enable) pdfViewersList;
in
  if (enabledPdfViewersCount == 0)
  # Use the fallback if no pdf viewer was enabled.
  then pdfViewers.fallback
  # Otherwise get the first enabled viewer.
  else builtins.head enabledPdfViewersList
