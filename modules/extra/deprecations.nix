{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule;
in {
  imports = [
    # 2024-06-06
    (mkRemovedOptionModule ["vim" "tidal"] ''
      Tidalcycles language support has been removed as of 2024-06-06 as it was long unmaintained. If
      you depended on this functionality, please open an issue.
    '')

    # 2024-07-20
    (mkRemovedOptionModule ["vim" "lsp" "nvimCodeActionMenu"] ''
      nvimCodeActionMenu has been deprecated and removed upstream. As of 0.7, fastaction will be
      available under `vim.ui.fastaction` as a replacement. Simply remove everything under
      `vim.lsp.nvimCodeActionMenu`, and set `vim.ui.fastaction.enable` to `true`.
    '')
  ];
}
