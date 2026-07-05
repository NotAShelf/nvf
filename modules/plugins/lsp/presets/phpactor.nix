{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.phpactor;
in {
  options.vim.lsp.presets.phpactor = {
    enable = mkLspPresetEnableOption {
      option = "phpactor";
      display = "PHPActor";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.phpactor = {
      enable = true;
      cmd = ["${pkgs.phpactor}/bin/phpactor" "language-server"];
      root_markers = [".git" ".phpactor.json" ".phpactor.yml"];
      workspace_required = true;
    };
  };
}
