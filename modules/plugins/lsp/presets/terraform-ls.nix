{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

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
      cmd = ["${pkgs.terraform-ls}/bin/terraform-ls" "serve"];
      root_markers = [".git"];
    };
  };
}
