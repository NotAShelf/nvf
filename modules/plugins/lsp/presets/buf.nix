{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.buf;
in {
  options.vim.lsp.presets.buf = {
    enable = mkLspPresetEnableOption {
      option = "buf";
      display = "Buf";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.buf = {
      enable = true;
      cmd = [(getExe pkgs.buf) "lsp" "serve" "--log-format=text"];
      root_markers = ["buf.yml" "buf.yaml" ".git"];
    };
  };
}
