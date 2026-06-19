{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.qmlformat;
in {
  options.vim.formatter.conform-nvim.presets.qmlformat = {
    enable = mkFormatterPresetEnableOption {
      option = "qmlformat";
      display = "QML";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.qmlformat = {
      command = "${pkgs.kdePackages.qtdeclarative}/bin/qmlformat";
      stdin = false;
      args = mkLuaInline ''
        function(self, ctx)
          local args = {
            "--indent-width",
            vim.bo[ctx.buf].shiftwidth,
          }

          if not vim.bo[ctx.buf].expandtab then
            table.insert(args, "--tabs")
          end

          table.insert(args, "--inplace")
          table.insert(args, "$FILENAME")

          return args
        end
      '';
    };
  };
}
