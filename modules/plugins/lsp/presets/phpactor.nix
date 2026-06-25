{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.phpactor;
in {
  options.vim.lsp.presets.phpactor = {
    enable = mkLspPresetEnableOption "phpactor" "PHPActor" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.phpactor = {
      enable = true;
      cmd = [(getExe pkgs.phpactor) "language-server"];
      root_markers = [".git" ".phpactor.json" ".phpactor.yml"];
      workspace_required = true;
    };
  };
}
