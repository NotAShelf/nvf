{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notify.nvim-notify;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-notify"];

    vim.luaConfigRC.nvim-notify = nvim.dag.entryAnywhere ''
      require('notify').setup {
        stages = "${cfg.stages}",
        timeout = ${toString cfg.timeout},
        background_colour = "${cfg.background_colour}",
        position = "${cfg.position}",
        icons = {
            ERROR = "${cfg.icons.ERROR}",
            WARN = "${cfg.icons.WARN}",
            INFO = "${cfg.icons.INFO}",
            DEBUG = "${cfg.icons.DEBUG}",
            TRACE = "${cfg.icons.TRACE}",
        },

      }
    '';
  };
}
