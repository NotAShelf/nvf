{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.debugger.nvim-dap.presets.xdebug;
in {
  options.vim.debugger.nvim-dap.presets.xdebug = {
    enable = mkEnableOption ''
      adapter configuration for Xdebug.
      Use {option}`vim.debugger.nvim-dap.adapters.xdebug` for customization.

      A configuration is also needed for your filetype in
      {option}`vim.debugger.nvim-dap.configurations`
    '';
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
