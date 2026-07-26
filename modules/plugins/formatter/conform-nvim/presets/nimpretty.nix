{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe';
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.nimpretty;
in {
  options.vim.formatter.conform-nvim.presets.nimpretty = {
    enable = mkFormatterPresetEnableOption {
      option = "nimpretty";
      display = "`nimpretty`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.nimpretty = {
      command = getExe' pkgs.nim "nimpretty";
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--indent:" .. ctx.shiftwidth,
            "$FILENAME",
          }
        end
      '';
    };
  };
}
