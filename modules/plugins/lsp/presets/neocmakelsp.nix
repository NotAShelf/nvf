{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.neocmakelsp;
in {
  options.vim.lsp.presets.neocmakelsp = {
    enable = mkLspPresetEnableOption "neocmakelsp" "NeoCmake" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.neocmakelsp = {
      enable = true;
      cmd = [(getExe pkgs.neocmakelsp) "stdio"];
      root_markers = [".git" ".gersemirc"];
      capabilities = {
        textDocument.completion.completionItem.snippetSupport = true;
      };
    };
  };
}
