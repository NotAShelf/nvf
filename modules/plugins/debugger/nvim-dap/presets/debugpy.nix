{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;

  cfg = config.vim.debugger.nvim-dap.presets.debugpy;
  package = pkgs.python3.withPackages (ps: with ps; [debugpy]);
in {
  options.vim.debugger.nvim-dap.presets.debugpy = {
    enable = mkEnableOption ''
      Debug adapter for debugpy.
      Use {option}`vim.debugger.nvim-dap.adapters.debugpy` for customization.

      A configuration is also needed for your filetype in
      {option}`vim.debugger.nvim-dap.configurations`
    '';
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    debugpy = mkLuaInline ''
      function(cb, config)
        if config.request == "attach" then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or "127.0.0.1"
          cb({
            type = "server",
            port = assert(port, "`connect.port` is required for a python `attach` configuration"),
            host = host,
            options = {
              source_filetype = "python",
            },
          })
        else
          cb({
            type = "executable",
            command = "${getExe package}",
            args = { "-m", "debugpy.adapter" },
            options = {
              source_filetype = "python",
            },
          })
        end
      end
    '';
  };
}
