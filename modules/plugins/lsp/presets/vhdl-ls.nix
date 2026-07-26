{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.vhdl-ls;
in {
  options.vim.lsp.presets.vhdl-ls = {
    enable = mkLspPresetEnableOption {
      option = "vhdl-ls";
      display = "VHDL";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vhdl-ls = {
      enable = true;
      cmd = [(getExe pkgs.vhdl-ls)];
      root_markers = [".git" "vhdl_ls.toml"];
    };
  };
}
