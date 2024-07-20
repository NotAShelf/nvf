{
  config,
  lib,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.binds) mkLuaBinding;

  cfg = config.vim.assistant.copilot;

  wrapPanelBinding = luaFunction: key: ''
    function()
      local s, _ = pcall(${luaFunction})

      if not s then
        local termcode = vim.api.nvim_replace_termcodes(${toJSON key}, true, false, true)

        vim.fn.feedkeys(termcode, 'n')
      end
    end
  '';
in {
  config = mkIf cfg.enable {
    vim.startPlugins =
      [
        "copilot-lua"
        # cfg.copilotNodePackage
      ]
      ++ optionals cfg.cmp.enable [
        "copilot-cmp"
      ];

    vim.pluginRC.copilot = entryAnywhere ''
      require("copilot").setup(${toLuaObject cfg.setupOpts})

      ${lib.optionalString cfg.cmp.enable ''
        require("copilot_cmp").setup()
      ''}
    '';

    # Disable plugin handled keymaps.
    # Setting it here so that it doesn't show up in user docs
    vim.assistant.copilot.setupOpts = {
      panel.keymap = {
        jump_prev = lib.mkDefault false;
        jump_next = lib.mkDefault false;
        accept = lib.mkDefault false;
        refresh = lib.mkDefault false;
        open = lib.mkDefault false;
      };
      suggestion.keymap = {
        accept = lib.mkDefault false;
        accept_word = lib.mkDefault false;
        accept_line = lib.mkDefault false;
        next = lib.mkDefault false;
        prev = lib.mkDefault false;
        dismiss = lib.mkDefault false;
      };
    };

    vim.maps.normal = mkMerge [
      (mkLuaBinding cfg.mappings.panel.jumpPrev (wrapPanelBinding "require(\"copilot.panel\").jump_prev" cfg.mappings.panel.jumpPrev) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.jumpNext (wrapPanelBinding "require(\"copilot.panel\").jump_next" cfg.mappings.panel.jumpNext) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.accept (wrapPanelBinding ''require("copilot.panel").accept'' cfg.mappings.panel.accept) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.refresh (wrapPanelBinding "require(\"copilot.panel\").refresh" cfg.mappings.panel.refresh) "[copilot] Accept suggestion")
      (mkLuaBinding cfg.mappings.panel.open (wrapPanelBinding ''
          function() require("copilot.panel").open({ position = "${cfg.setupOpts.panel.layout.position}", ratio = ${toString cfg.setupOpts.panel.layout.ratio}, }) end
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
