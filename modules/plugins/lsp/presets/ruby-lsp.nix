{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.ruby-lsp;
in {
  options.vim.lsp.presets.ruby-lsp = {
    enable = mkLspPresetEnableOption "ruby-lsp" "Ruby" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ruby-lsp = {
      enable = true;
      cmd = [(getExe pkgs.ruby-lsp)];
      root_markers = [".git"];
      init_options = {
        formatter = "auto";
      };
    };
  };
}
