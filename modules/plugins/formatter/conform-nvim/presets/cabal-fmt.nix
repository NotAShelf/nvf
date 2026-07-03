{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.cabal-fmt;
in {
  options.vim.formatter.conform-nvim.presets.cabal-fmt = {
    enable = mkFormatterPresetEnableOption {
      option = "cabal-fmt";
      display = "`cabal-fmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.cabal-fmt = {
      command = "${pkgs.haskellPackages.cabal-fmt}/bin/cabal-fmt";
      stdin = false;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--indent", vim.bo[ctx.buf].shiftwidth,
            "--inplace", "$FILENAME"
          }
        end
      '';
    };
  };
}
