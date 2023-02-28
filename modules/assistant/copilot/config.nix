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
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "copilot-lua"
      pkgs.nodejs-slim-16_x
    ];

    vim.luaConfigRC.copilot = nvim.dag.entryAnywhere ''
      require("copilot").setup({
        -- available options: https://github.com/zbirenbaum/copilot.lua
        copilot_node_command = "${cfg.copilot_node_command}",
      })
    '';
  };
}
