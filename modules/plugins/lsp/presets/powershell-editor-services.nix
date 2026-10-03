{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.powershell-editor-services;
in {
  options.vim.lsp.presets.powershell-editor-services = {
    enable = mkLspPresetEnableOption {
      option = "powershell-editor-services";
      display = "PowerShell Editor Services";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.powershell-editor-services = {
      enable = true;
      cmd = [(getExe pkgs.powershell-editor-services) "-LogLevel" "Error" "-Stdio"];
      root_markers = [".git"];
    };
  };
}
