{lib, ...}:
with lib; {
  options.vim.debugger.nvim-dap = {
    enable = mkEnableOption "Enable debugging via nvim-dap";

    ui = {
      enable = mkEnableOption "Enable UI extension for nvim-dap";
      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically Opens and Closes DAP-UI upon starting/closing a debugging session";
      };
    };

    sources = mkOption {
      default = {};
      description = "List of debuggers to install";
      type = with types; attrsOf string;
    };
  };
}
