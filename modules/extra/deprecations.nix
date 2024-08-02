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
      nvimCodeActionMenu has been deprecated and archived upstream. As of 0.7, code-actions will be
      available under `vim.lsp.code-actions.enable` and `vim.lsp.code.actions.<plugin>.enable`.
      Please take a look at the nvf manual for more details.
    '')
  ];
}
