{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.vhdl-ls;
in {
  options.vim.lsp.presets.vhdl-ls = {
    enable = mkLspPresetEnableOption "vhdl-ls" "VHDL" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vhdl-ls = {
      enable = true;
      cmd = [(getExe pkgs.vhdl-ls)];
      root_markers = [".git" "vhdl_ls.toml"];
    };
  };
}
