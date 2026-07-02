{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.taplo;
in {
  options.vim.formatter.conform-nvim.presets.taplo = {
    enable = mkFormatterPresetEnableOption {
      option = "taplo";
      display = "Taplo";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.taplo = {
      command = "${pkgs.taplo}/bin/taplo";
      args = mkLuaInline ''
        function(self, ctx)
          local indent = not vim.bo[ctx.buf].expandtab and "\t" or string.rep(" ", vim.bo[ctx.buf].shiftwidth)
          return {
            "format",
            "--stdin-filepath",
            "$FILENAME",
            "--option=align_entries=true",
            "--option=inden_string=" .. indent,
            "-"
          }
        end
      '';
    };
  };
}
