{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notify.nvim-notify;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-notify"];

      luaConfigRC.nvim-notify = entryAnywhere ''
        require('notify').setup(${toLuaObject cfg.setupOpts})

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
  };
}
