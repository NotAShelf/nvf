{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.nasmfmt;
in {
  options.vim.formatter.conform-nvim.presets.nasmfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "nasmfmt";
      display = "`nasmfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.nasmfmt = {
      command = "${pkgs.nasmfmt}/bin/nasmfmt";
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--ii", ctx.shiftwidth,
            "$FILENAME",
          }
        end
      '';
    };
  };
}
