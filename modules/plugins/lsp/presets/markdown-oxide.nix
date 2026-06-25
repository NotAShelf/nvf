{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.markdown-oxide;
in {
  options.vim.lsp.presets.markdown-oxide = {
    enable = mkLspPresetEnableOption "markdown-oxide" "Markdown Oxide" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.markdown-oxide = {
      enable = true;
      cmd = [(getExe pkgs.markdown-oxide)];
      root_markers = [".git" ".moxide.toml" ".obsidian"];
    };
  };
}
