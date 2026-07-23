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

  cfg = config.vim.formatter.conform-nvim.presets.isort;
in {
  options.vim.formatter.conform-nvim.presets.isort = {
    enable = mkFormatterPresetEnableOption {
      option = "isort";
      display = "`isort`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.isort = {
      command = getExe pkgs.isort;
      args = mkLuaInline ''
        function(self, ctx)
          local indent = vim.bo[ctx.buf].expandtab and string.rep(" ", vim.bo[ctx.buf].shiftwidth) or "\t"
          return {
            "--stdout",
            "--indent", indent,
            "--filename", "$FILENAME",
            "-",
          }
        end
      '';
    };
  };
}
