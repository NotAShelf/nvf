{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe';

  cfg = config.vim.lsp.presets.typescript-go;
in {
  options.vim.lsp.presets.typescript-go = {
    enable = mkLspPresetEnableOption {
      option = "typescript-go";
      display = "TypeScript Go";
      extra = "Experimental.";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.typescript-go = {
      enable = true;
      cmd = [(getExe' pkgs.typescript-go "tsgo") "--lsp" "--stdio"];
      root_markers = [".git" "tsconfig.json" "package.json"];
    };
  };
}
