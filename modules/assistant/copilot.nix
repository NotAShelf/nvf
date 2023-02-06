{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.assistant.copilot;
in {
  options.vim.assistant.copilot = {
    enable = mkEnableOption "Enable GitHub Copilot";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["copilot-lua"];

    vim.luaConfigRC.copilot = nvim.dag.entryAnywhere ''
      require("copilot").setup({
        -- available options: https://github.com/zbirenbaum/copilot.lua
      })
    '';
  };
}
