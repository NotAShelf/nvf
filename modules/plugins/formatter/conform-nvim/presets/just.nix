{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.just;
in {
  options.vim.formatter.conform-nvim.presets.just = {
    enable = mkFormatterPresetEnableOption {
      option = "just";
      display = "Just";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.just = {
      command = getExe pkgs.just;
      stdin = false;
      args = mkLuaInline ''
        function(self, ctx)
          local indent = not vim.bo[ctx.buf].expandtab and "\t" or string.rep(" ", vim.bo[ctx.buf].shiftwidth)
          return {
            "--fmt",
            "--indentation", indent,
            "--justfile",
            "$FILENAME",
          }
        end
      '';
    };
  };
}
