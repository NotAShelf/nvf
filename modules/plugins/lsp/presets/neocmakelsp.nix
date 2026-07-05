{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.neocmakelsp;
in {
  options.vim.lsp.presets.neocmakelsp = {
    enable = mkLspPresetEnableOption {
      option = "neocmakelsp";
      display = "Neo CMake";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.neocmakelsp = {
      enable = true;
      cmd = ["${pkgs.neocmakelsp}/bin/neocmakelsp" "stdio"];
      root_markers = [".git" ".gersemirc"];
      capabilities = {
        textDocument.completion.completionItem.snippetSupport = true;
      };
    };
  };
}
