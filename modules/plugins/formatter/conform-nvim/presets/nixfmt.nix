{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.nixfmt;
in {
  options.vim.formatter.conform-nvim.presets.nixfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "nixfmt";
      display = "`nixfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.nixfmt = {
      command = "${pkgs.nixfmt}/bin/nixfmt";
      args = mkLuaInline ''
        function(self, ctx)
          return {"--indent=" .. ctx.shiftwidth}
        end
      '';
    };
  };
}
