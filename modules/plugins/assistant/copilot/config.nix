{
  config,
  lib,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.modules) mkIf;

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

  mkLuaKeymap = mode: key: action: desc: opts:
    opts
    // {
      inherit mode key action desc;
      lua = true;
    };
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins = {
        copilot-lua = {
          package = "copilot-lua";
          setupModule = "copilot";
          inherit (cfg) setupOpts;
          after = mkIf cfg.cmp.enable "require('copilot_cmp').setup()";

          event = [
            {
              event = "User";
              pattern = "LazyFile";
            }
          ];
          cmd = ["Copilot" "CopilotAuth" "CopilotDetach" "CopilotPanel" "CopilotStop"];
          keys = [
            (mkLuaKeymap ["n"] cfg.mappings.panel.accept (wrapPanelBinding ''require("copilot.panel").accept'' cfg.mappings.panel.accept) "[copilot] Accept suggestion" {})
            (mkLuaKeymap ["n"] cfg.mappings.panel.jumpNext (wrapPanelBinding "require(\"copilot.panel\").jump_next" cfg.mappings.panel.jumpNext) "[copilot] Next panel suggestion" {})
            (mkLuaKeymap ["n"] cfg.mappings.panel.jumpPrev (wrapPanelBinding "require(\"copilot.panel\").jump_prev" cfg.mappings.panel.jumpPrev) "[copilot] Previous panel suggestion" {})
            (mkLuaKeymap ["n"] cfg.mappings.panel.refresh (wrapPanelBinding "require(\"copilot.panel\").refresh" cfg.mappings.panel.refresh) "[copilot] Refresh suggestion" {})
            (mkLuaKeymap ["n"] cfg.mappings.panel.open (wrapPanelBinding ''
                function() require("copilot.panel").open({ position = "${cfg.setupOpts.panel.layout.position}", ratio = ${toString cfg.setupOpts.panel.layout.ratio}, }) end
              ''
              cfg.mappings.panel.open) "[copilot] Open Panel" {})

            (mkLuaKeymap ["i"] cfg.mappings.suggestion.accept "function() require('copilot.suggestion').accept() end" "[copilot] Accept suggestion" {})
            (mkLuaKeymap ["i"] cfg.mappings.suggestion.acceptLine "function() require('copilot.suggestion').accept_line() end" "[copilot] Accept suggestion (line)" {})
            (mkLuaKeymap ["i"] cfg.mappings.suggestion.acceptWord "function() require('copilot.suggestion').accept_word() end" "[copilot] Accept suggestion (word)" {})
            (mkLuaKeymap ["i"] cfg.mappings.suggestion.dismiss "function() require('copilot.suggestion').dismiss() end" "[copilot] dismiss suggestion" {})
            (mkLuaKeymap ["i"] cfg.mappings.suggestion.next "function() require('copilot.suggestion').next() end" "[copilot] next suggestion" {})
            (mkLuaKeymap ["i"] cfg.mappings.suggestion.prev "function() require('copilot.suggestion').prev() end" "[copilot] previous suggestion" {})
          ];
        };
      };

      autocomplete.nvim-cmp = {
        sources = {copilot = "[Copilot]";};
        sourcePlugins = ["copilot-cmp"];
      };

      # Disable plugin handled keymaps.
      # Setting it here so that it doesn't show up in user docs
      assistant.copilot.setupOpts = {
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
    };
  };
}
