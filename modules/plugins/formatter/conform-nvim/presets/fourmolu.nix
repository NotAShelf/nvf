{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.fourmolu;
in {
  options.vim.formatter.conform-nvim.presets.fourmolu = {
    enable = mkFormatterPresetEnableOption {
      option = "fourmolu";
      display = "Fourmolu";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.fourmolu = {
      command = "${pkgs.haskellPackages.fourmolu}/bin/fourmolu";
      stdin = true;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--indentation", vim.bo[ctx.buf].shiftwidth,
            "--stdin-input-file", "$FILENAME"
          }
        end
      '';
    };
  };
}
