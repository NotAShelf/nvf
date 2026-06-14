{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.gersemi;
in {
  options.vim.formatter.conform-nvim.presets.gersemi = {
    enable = mkFormatterPresetEnableOption {
      option = "gersemi";
      display = "`gersemi`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.gersemi = {
      command = "${pkgs.gersemi}/bin/gersemi";
      args = mkLuaInline ''
        function(self, ctx)
          local indent = vim.bo[ctx.buf].expandtab and vim.bo[ctx.buf].shiftwidth or "tabs"
          return {
            "--quiet",
            "--indent", indent,
            "-",
          }
        end
      '';
    };
  };
}
