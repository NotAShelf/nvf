{lib, ...}: {
  options.vim.ui.breadcrumbs = {
    enable = lib.mkEnableOption "breadcrumbs";
  };
}
