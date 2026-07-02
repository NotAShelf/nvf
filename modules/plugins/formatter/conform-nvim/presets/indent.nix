{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.indent;
in {
  options.vim.formatter.conform-nvim.presets.indent = {
    enable = mkFormatterPresetEnableOption {
      option = "indent";
      display = "GNU Indent";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.indent = {
      command = "${pkgs.indent}/bin/indent";
      stdin = true;
      args = mkLuaInline ''
        function(self, ctx)
          local indent = vim.bo[ctx.buf].expandtab and "--no-tabs" or "--use-tabs"

          return {
            "--indent-level", ctx.shiftwidth,
            "--tab-size", ctx.shiftwidth,
            indent
          }
        end
      '';
      # Default is GNU style. Nobody likes that one.
      # This is under `append_args`, to allow easy editing of this argument,
      # without having to redefine everything as a user.
      append_args = ["--linux-style"];
    };
  };
}
