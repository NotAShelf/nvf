{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.lsp = {
    lsplines = {
      enable = mkEnableOption "diagnostics using virtual lines on top of the real line of code. [lsp_lines]";
    };
  };
}
