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
        panel = {
          keymap = {
            jump_prev = false,
            jump_next = false,
            accept = false,
            refresh = false,
            open = false,
          },
          layout = {
            position = "${cfg.panel.position}",
            ratio = ${toString cfg.panel.ratio},
          },
        },
        suggestion = {
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = false,
            next = false,
            prev = false,
            dismiss = false,
          },
        },
      })
    '';

    vim.maps.normal = mkMerge [
      (mkLuaBinding cfg.mappings.panel.jumpPrev "require(\"copilot.panel\").jump_prev" "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.jumpNext "require(\"copilot.panel\").jump_next" "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.accept "require(\"copilot.panel\").accept" "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.refresh "require(\"copilot.panel\").refresh" "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.open ''
        function() require("copilot.panel").open({ position = "${cfg.panel.position}", ratio = ${toString cfg.panel.ratio}, }) end
      '' "[copilot] Accept suggestion")
    ];

    vim.maps.insert = mkMerge [
      (mkLuaBinding cfg.mappings.suggestion.accept "require(\"copilot.suggestion\").accept" "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.suggestion.acceptLine "require(\"copilot.suggestion\").accept_line" "[copilot] Accept suggestion (line)")
      (mkLuaBinding cfg.mappings.suggestion.acceptWord "require(\"copilot.suggestion\").accept_word" "[copilot] Accept suggestion (word)")
      (mkLuaBinding cfg.mappings.suggestion.next "require(\"copilot.suggestion\").next" "[copilot] next suggestion")
      (mkLuaBinding cfg.mappings.suggestion.prev "require(\"copilot.suggestion\").prev" "[copilot] previous suggestion")
      (mkLuaBinding cfg.mappings.suggestion.dismiss "require(\"copilot.suggestion\").dismiss" "[copilot] dismiss suggestion")
    ];
  };
}
