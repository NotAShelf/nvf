{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalMD;
  inherit (lib.types) listOf str either attrsOf submodule enum anything int;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.config) mkBool;

  keymapType = submodule {
    freeformType = attrsOf (listOf (either str luaInline));
    options = {
      preset = mkOption {
        type = enum ["default" "none" "super-tab" "enter"];
        default = "none";
        description = "keymap presets";
      };
    };
  };

  providerType = submodule {
    freeformType = anything;
    options = {
      module = mkOption {
        type = str;
        description = "module of the provider";
      };
    };
  };
in {
  options.vim.autocomplete.blink-cmp = {
    enable = mkEnableOption "blink.cmp";
    setupOpts = mkPluginSetupOption "blink.cmp" {
      sources = {
        default = mkOption {
          type = listOf str;
          default = ["lsp" "path" "snippets" "buffer"];
          description = "Default list of sources to enable for completion.";
        };

        cmdline = mkOption {
          type = listOf str;
          default = [];
          description = "List of sources to enable for cmdline";
        };

        providers = mkOption {
          type = attrsOf providerType;
          default = {};
          description = "Providers";
        };
      };

      completion = {
        documentation = {
          auto_show = mkBool true "Show documentation whenever an item is selected";
          auto_show_delay_ms = mkOption {
            type = int;
            default = 200;
            description = "Delay before auto show triggers";
          };
        };
      };

      keymap = mkOption {
        type = keymapType;
        default = {};
        description = "blink.cmp keymap";
        example = literalMD ''
          ```nix
          vim.autocomplete.blink-cmp.setupOpts.keymap = {
            preset = "none";

            "<Up>" = ["select_prev" "fallback"];
            "<C-n>" = [
              (lib.generators.mkLuaInline ''''
                function(cmp)
                  if some_condition then return end -- runs the next command
                    return true -- doesn't run the next command
                  end,
              '''')
              "select_next"
            ];
          };
          ```
        '';
      };
    };

    mappings = {
      complete = mkMappingOption "Complete [blink.cmp]" "<C-Space>";
      confirm = mkMappingOption "Confirm [blink.cmp]" "<CR>";
      next = mkMappingOption "Next item [blink.cmp]" "<Tab>";
      previous = mkMappingOption "Previous item [blink.cmp]" "<S-Tab>";
      close = mkMappingOption "Close [blink.cmp]" "<C-e>";
      scrollDocsUp = mkMappingOption "Scroll docs up [blink.cmp]" "<C-d>";
      scrollDocsDown = mkMappingOption "Scroll docs down [blink.cmp]" "<C-f>";
    };
  };
}
