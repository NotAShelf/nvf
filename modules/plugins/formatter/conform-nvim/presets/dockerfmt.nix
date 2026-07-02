{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.dockerfmt;
in {
  options.vim.formatter.conform-nvim.presets.dockerfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "dockerfmt";
      display = "`dockerfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.dockerfmt = {
      command = "${pkgs.dockerfmt}/bin/dockerfmt";
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--indent", ctx.shiftwidth,
          }
        end
      '';
    };
  };
}
