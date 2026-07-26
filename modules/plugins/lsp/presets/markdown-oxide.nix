{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.markdown-oxide;
in {
  options.vim.lsp.presets.markdown-oxide = {
    enable = mkLspPresetEnableOption {
      option = "markdown-oxide";
      display = "Markdown Oxide";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.markdown-oxide = {
      enable = true;
      cmd = [(getExe pkgs.markdown-oxide)];
      root_markers = [".git" ".moxide.toml" ".obsidian"];
    };
  };
}
