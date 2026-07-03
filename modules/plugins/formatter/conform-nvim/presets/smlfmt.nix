{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.smlfmt;
in {
  options.vim.formatter.conform-nvim.presets.smlfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "smlfmt";
      display = "`smlfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.smlfmt = {
      command = "${pkgs.smlfmt}/bin/smlfmt";
      stdin = false;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--force",
            "-tab-width", ctx.shiftwidth,
            "-indent-width", ctx.shiftwidth,
            "$FILENAME",
          }
        end
      '';
    };
  };
}
