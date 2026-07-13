{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.ts-query-ls;
in {
  options.vim.lsp.presets.ts-query-ls = {
    enable = mkLspPresetEnableOption {
      option = "ts-query-ls";
      display = "Treesitter Query";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ts-query-ls = {
      enable = true;
      cmd = ["${pkgs.ts_query_ls}/bin/ts_query_ls"];
    };
  };
}
