{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.rumdl;
in {
  options.vim.formatter.conform-nvim.presets.rumdl = {
    enable = mkFormatterPresetEnableOption {
      option = "rumdl";
      display = "`rumdl`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.rumdl = {
      command = "${pkgs.rumdl}/bin/rumdl";
      stdin = true;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "fmt",
            "--stdin",
            "--stdin-filename", "$FILENAME",
            "--config", "MD007.indent = " .. vim.bo[ctx.buf].shiftwidth,
            "-",
          }
        end
      '';
    };
  };
}
