{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.formatter.conform-nvim.presets.astyle;
  opts = config.vim.formatter.conform-nvim.setupOpts.formatters.astyle.options;
in {
  options.vim.formatter.conform-nvim.presets.astyle = {
    enable = mkFormatterPresetEnableOption {
      option = "astyle";
      display = "Artistic Style";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.astyle = {
      command = "${pkgs.astyle}/bin/astyle";
      stdin = false;
      options = {
        filetype_mode = {
          c = "c";
          cpp = "c";
          obj = "objc";
          objcpp = "objc";
          java = "java";
          cs = "cs";
          javascript = "js";
          typescript = "js";
        };
      };

      args = mkLuaInline ''
        function(self, ctx)
          local indent = not vim.bo[ctx.buf].expandtab and "tab" or "spaces"

          local mode = (${toLuaObject opts.filetype_mode})[vim.bo[ctx.buf].filetype]
          mode = mode and ("--mode=" .. mode) or ""

          return {
            "--indent=" .. indent .. "=" .. ctx.shiftwidth,
            mode,
            "$FILENAME",
          }
        end
      '';
    };
  };
}
