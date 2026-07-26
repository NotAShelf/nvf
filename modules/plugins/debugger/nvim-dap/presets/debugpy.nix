{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkDapPresetEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.debugpy;
  package = pkgs.python3.withPackages (ps: with ps; [debugpy]);
in {
  options.vim.debugger.nvim-dap.presets.debugpy = {
    enable = mkDapPresetEnableOption {
      option = "debugpy";
      display = "`debugpy`";
      extra = ''
        See <https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings>
        for supported options.
      '';
    };
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
