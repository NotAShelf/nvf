{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notify.nvim-notify;
in {
  options.vim.notify.nvim-notify = {
    enable = mkEnableOption "Enable nvim-notify plugin";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-notify"];

    vim.luaConfigRC.nvim-notify = nvim.dag.entryAnywhere ''
      require('notify').setup {
        stages = 'fade_in_slide_out',
        timeout = 1000,
        background_colour = '#000000',
        position = 'top_right',
        icons = {
          ERROR = '',
          WARN = '',
          INFO = '',
          DEBUG = '',
          TRACE = '',
        },
      }
    '';
  };
}
