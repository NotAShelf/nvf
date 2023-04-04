{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.assistant.copilot;
  keyOrFalse = key:
    if key != null
    then "'${key}'"
    else "false";
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
        panel = {
          keymap = {
            jump_prev = ${keyOrFalse cfg.mappings.panel.jumpPrev},
            jump_next = ${keyOrFalse cfg.mappings.panel.jumpNext},
            accept = ${keyOrFalse cfg.mappings.panel.accept},
            refresh = ${keyOrFalse cfg.mappings.panel.refresh},
            open = ${keyOrFalse cfg.mappings.panel.open},
          },
        },
        suggestion = {
          keymap = {
            accept = ${keyOrFalse cfg.mappings.suggestion.accept},
            accept_word = ${keyOrFalse cfg.mappings.suggestion.acceptWord},
            accept_line = ${keyOrFalse cfg.mappings.suggestion.acceptLine},
            next = ${keyOrFalse cfg.mappings.suggestion.next},
            prev = ${keyOrFalse cfg.mappings.suggestion.prev},
            dismiss = ${keyOrFalse cfg.mappings.suggestion.dismiss},
          },
        },
      })
    '';
  };
}
