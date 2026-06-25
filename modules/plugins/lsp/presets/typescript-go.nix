{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.typescript-go;
in {
  options.vim.lsp.presets.typescript-go = {
    enable = mkLspPresetEnableOption "typescript-go" "experimental TypeScript Go" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.typescript-go = {
      enable = true;
      cmd = [(getExe pkgs.typescript-go) "--lsp" "--stdio"];
      root_markers = [".git" "tsconfig.json" "package.json"];
    };
  };
}
