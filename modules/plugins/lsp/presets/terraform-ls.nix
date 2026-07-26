{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.terraform-ls;
in {
  options.vim.lsp.presets.terraform-ls = {
    enable = mkLspPresetEnableOption {
      option = "terraform-ls";
      display = "Terraform";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.terraform-ls = {
      enable = true;
      cmd = [(getExe pkgs.terraform-ls) "serve"];
      root_markers = [".git"];
    };
  };
}
