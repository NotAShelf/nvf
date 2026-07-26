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

  cfg = config.vim.formatter.conform-nvim.presets.djlint;
in {
  options.vim.formatter.conform-nvim.presets.djlint = {
    enable = mkFormatterPresetEnableOption {
      option = "djlint";
      display = "djLint";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.djlint = {
      command = getExe pkgs.djlint;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--indent", ctx.shiftwidth,
            "$FILENAME",
            "--reformat",
            "-",
          }
        end
      '';
    };
  };
}
