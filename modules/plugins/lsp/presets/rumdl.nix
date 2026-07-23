{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.rumdl;
in {
  options.vim.lsp.presets.rumdl = {
    enable = mkLspPresetEnableOption {
      option = "rumdl";
      display = "Rumdl";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.rumdl = {
      enable = true;
      cmd = [(getExe pkgs.rumdl) "server"];
      root_markers = [".git" ".rumdl.toml" "rumdl.toml" ".config/rumdl.toml" "pyproject.toml"];
    };
  };
}
