{lib, ...}:
with lib; {
  options.vim.debugger.nvim-dap = {
    enable = mkEnableOption "Enable debugging via nvim-dap";

    ui = {
      enable = mkEnableOption "Enable UI extension for nvim-dap";
    };
  };
}
