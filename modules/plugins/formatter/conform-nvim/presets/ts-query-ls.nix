{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.ts-query-ls;
in {
  options.vim.formatter.conform-nvim.presets.ts-query-ls.enable = mkFormatterPresetEnableOption {
    option = "ts-query-ls";
    display = "`ts_query_ls`";
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.ts-query-ls = {
      stdin = false;
      command = getExe pkgs.ts_query_ls;
      args = [
        "format"
        "$FILENAME"
      ];
      # it only formats files ending in `.scm`
      tmpfile_format = "conform.$RANDOM.$FILENAME.scm";
    };
  };
}
