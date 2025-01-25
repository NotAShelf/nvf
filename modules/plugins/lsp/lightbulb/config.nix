{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lightbulb.enable) {
    vim = {
      startPlugins = ["nvim-lightbulb"];
      pluginRC.lightbulb = entryAnywhere ''
        local nvim_lightbulb = require("nvim-lightbulb")
        nvim_lightbulb.setup(${toLuaObject cfg.lightbulb.setupOpts})
        ${optionalString cfg.lightbulb.autocmd.enable ''
          vim.api.nvim_create_autocmd(${toLuaObject cfg.lightbulb.autocmd.events}, {
            pattern = ${toLuaObject cfg.lightbulb.autocmd.pattern},
            callback = function()
              nvim_lightbulb.update_lightbulb()
            end,
          })
        ''}
      '';
    };

    warnings = [
      # This could have been an assertion, but the chances of collision is very low and asserting here
      # might be too dramatic. Let's only warn the user, *in case* this occurs and is not intended. No
      # error will be thrown if 'lightbulb.setupOpts.autocmd.enable' has not been set by the user.
      (mkIf (cfg.lightbulb.autocmd.enable -> (cfg.lightbulb.setupOpts.autocmd.enabled or false)) ''
        Both 'vim.lsp.lightbulb.autocmd.enable' and 'vim.lsp.lightbulb.setupOpts.autocmd.enable' are set
        simultaneously. This might have performance implications due to frequent updates. Please set only
        one option to handle nvim-lightbulb autocmd.
      '')
    ];
  };
}
