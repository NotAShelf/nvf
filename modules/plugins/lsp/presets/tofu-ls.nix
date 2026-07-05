{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.tofu-ls;
in {
  options.vim.lsp.presets.tofu-ls = {
    enable = mkLspPresetEnableOption {
      option = "tofu-ls";
      display = "OpenTofu";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.tofu-ls = {
      enable = true;
      cmd = ["${pkgs.tofu-ls}/bin/tofu-ls" "serve"];
      root_markers = [".git"];
    };
  };
}
