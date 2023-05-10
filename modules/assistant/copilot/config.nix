{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.assistant.copilot;

  wrapPanelBinding = luaFunction: key: ''
    function()
      local s, _ = pcall(${luaFunction})

      if not s then
        local termcode = vim.api.nvim_replace_termcodes(${builtins.toJSON key}, true, false, true)

        vim.fn.feedkeys(termcode, 'n')
      end
    end
  '';
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "copilot-lua"
      cfg.copilotNodePackage
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
      (mkLuaBinding cfg.mappings.panel.jumpPrev (wrapPanelBinding "require(\"copilot.panel\").jump_prev" cfg.mappings.panel.jumpPrev) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.jumpNext (wrapPanelBinding "require(\"copilot.panel\").jump_next" cfg.mappings.panel.jumpNext) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.accept (wrapPanelBinding ''require("copilot.panel").accept'' cfg.mappings.panel.accept) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.refresh (wrapPanelBinding "require(\"copilot.panel\").refresh" cfg.mappings.panel.refresh) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.open (wrapPanelBinding ''
          function() require("copilot.panel").open({ position = "${cfg.panel.position}", ratio = ${toString cfg.panel.ratio}, }) end
        ''
        cfg.mappings.panel.open) "[copilot] Accept suggestion")
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
