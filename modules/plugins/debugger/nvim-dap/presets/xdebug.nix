{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkDapPresetEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.xdebug;
in {
  options.vim.debugger.nvim-dap.presets.xdebug = {
    enable = mkDapPresetEnableOption {
      option = "xdebug";
      display = "Xdebug";
    };
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    xdebug = {
      type = "executable";
      command = getExe pkgs.nodejs;
      args = [
        "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"
      ];
    };
  };
}
