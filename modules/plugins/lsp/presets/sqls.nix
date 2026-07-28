{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.sqls;
in {
  options.vim.lsp.presets.sqls = {
    enable = mkLspPresetEnableOption {
      option = "sqls";
      display = "SQL";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.sqls = {
      enable = true;
      cmd = [(getExe pkgs.sqls)];
      root_markers = ["config.yml"];
    };
  };
}
