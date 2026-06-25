{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.tofu-ls;
in {
  options.vim.lsp.presets.tofu-ls = {
    enable = mkLspPresetEnableOption "tofu-ls" "OpenTofu" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.tofu-ls = {
      enable = true;
      cmd = [(getExe pkgs.tofu-ls) "serve"];
      root_markers = [".git"];
    };
  };
}
