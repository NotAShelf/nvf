{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.ruby-lsp;
in {
  options.vim.lsp.presets.ruby-lsp = {
    enable = mkLspPresetEnableOption {
      option = "ruby-lsp";
      display = "Ruby";
    };
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
