{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

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

      -- required to fix offset_encoding errors
      local notify = vim.notify
      vim.notify = function(msg, ...)
        if msg:match("warning: multiple different client offset_encodings") then
          return
        end

        notify(msg, ...)
      end
    '';
  };
}
