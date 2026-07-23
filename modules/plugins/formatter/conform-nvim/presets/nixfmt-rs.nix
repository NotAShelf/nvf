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

  cfg = config.vim.formatter.conform-nvim.presets.nixfmt-rs;
in {
  options.vim.formatter.conform-nvim.presets.nixfmt-rs = {
    enable = mkFormatterPresetEnableOption {
      option = "nixfmt-rs";
      display = "`nixfmt-rs`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.nixfmt-rs = {
      command = getExe pkgs.nixfmt-rs;
      args = mkLuaInline ''
        function(self, ctx)
          return {"--indent=" .. ctx.shiftwidth}
        end
      '';
    };
  };
}
