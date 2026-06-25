{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.rumdl;
in {
  options.vim.lsp.presets.rumdl = {
    enable = mkLspPresetEnableOption "rumdl" "Rumdl" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.rumdl = {
      enable = true;
      cmd = [(getExe pkgs.rumdl) "server"];
      root_markers = [".git" ".rumdl.toml" "rumdl.toml" ".config/rumdl.toml" "pyproject.toml"];
    };
  };
}
