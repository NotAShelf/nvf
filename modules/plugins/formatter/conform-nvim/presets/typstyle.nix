{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.typstyle;
in {
  options.vim.formatter.conform-nvim.presets.typstyle = {
    enable = mkFormatterPresetEnableOption {
      option = "typstyle";
      display = "Typstyle";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.typstyle = {
      command = "${pkgs.typstyle}/bin/typstyle";
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--inplace",
            "--indent-width",
            vim.bo[ctx.buf].shiftwidth,
            "$FILENAME"
          }
        end
      '';
      stdin = false;
    };
  };
}
