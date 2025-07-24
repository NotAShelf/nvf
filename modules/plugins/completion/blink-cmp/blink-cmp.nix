{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalMD;
  inherit (lib.types) bool listOf str either attrsOf submodule enum anything int nullOr;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline pluginType;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.config) mkBool;

  keymapType = submodule {
    freeformType = attrsOf (listOf (either str luaInline));
    options = {
      preset = mkOption {
        type = enum ["default" "none" "super-tab" "enter" "cmdline"];
        default = "none";
        description = "keymap presets";
      };
    };
  };

  providerType = submodule {
    freeformType = anything;
    options = {
      module = mkOption {
        type = nullOr str;
        default = null;
        description = "Provider module.";
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

        providers = mkOption {
          type = attrsOf providerType;
          default = {};
          description = "Settings for completion providers.";
        };
      };

      cmdline = {
        sources = mkOption {
          type = nullOr (listOf str);
          default = null;
          description = "List of sources to enable for cmdline. Null means use default source list.";
        };

        keymap = mkOption {
          type = keymapType;
          default = {};
          description = "blink.cmp cmdline keymap";
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

        menu.auto_show = mkOption {
          type = bool;
          default = true;
          description = ''
            Manages the appearance of the completion menu. You may prevent the menu
            from automatically showing by this option to `false` and manually showing
            it with the show keymap command.
          '';
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

      fuzzy = {
        prebuilt_binaries = {
          download = mkBool false ''
            Auto-downloads prebuilt binaries.

            ::: .{warning}
            Do not enable this option, as it does **not work** on Nix!
            :::
          '';
        };

        implementation = mkOption {
          type = enum ["lua" "prefer_rust" "rust" "prefer_rust_with_warning"];
          default = "prefer_rust";
          description = ''
            fuzzy matcher implementation for Blink.

            * `"lua"`: slower, Lua native fuzzy matcher implementation
            * `"rust": use the SIMD fuzzy matcher, 'frizbee'
            * `"prefer_rust"`: use the rust implementation, but fall back to lua
            * `"prefer_rust_with_warning"`: use the rust implementation, and fall back to lua
              if it is not available after emitting a warning.
          '';
        };
      };
    };

    mappings = {
      complete = mkMappingOption config.vim.enableNvfKeymaps "Complete [blink.cmp]" "<C-Space>";
      confirm = mkMappingOption config.vim.enableNvfKeymaps "Confirm [blink.cmp]" "<CR>";
      next = mkMappingOption config.vim.enableNvfKeymaps "Next item [blink.cmp]" "<Tab>";
      previous = mkMappingOption config.vim.enableNvfKeymaps "Previous item [blink.cmp]" "<S-Tab>";
      close = mkMappingOption config.vim.enableNvfKeymaps "Close [blink.cmp]" "<C-e>";
      scrollDocsUp = mkMappingOption config.vim.enableNvfKeymaps "Scroll docs up [blink.cmp]" "<C-d>";
      scrollDocsDown = mkMappingOption config.vim.enableNvfKeymaps "Scroll docs down [blink.cmp]" "<C-f>";
    };

    sourcePlugins = let
      sourcePluginType = submodule {
        options = {
          enable = mkEnableOption "this source";
          package = mkOption {
            type = pluginType;
            description = ''
              `blink-cmp` source plugin package.
            '';
          };

          module = mkOption {
            type = str;
            description = ''
              Value of {option}`vim.autocomplete.blink-cmp.setupOpts.sources.providers.<name>.module`.

              Should be present in the source's documentation.
            '';
          };
        };
      };
    in
      mkOption {
        type = submodule {
          freeformType = attrsOf sourcePluginType;
          options = let
            defaultSourcePluginOption = name: package: module: {
              package = mkOption {
                type = pluginType;
                default = package;
                description = ''
                  `blink-cmp` ${name} source plugin package.
                '';
              };
              module = mkOption {
                type = str;
                default = module;
                description = ''
                  Value of {option}`vim.autocomplete.blink-cmp.setupOpts.sources.providers.${name}.module`.
                '';
              };
              enable = mkEnableOption "${name} source";
            };
          in {
            # emoji completion after :
            emoji = defaultSourcePluginOption "emoji" "blink-emoji-nvim" "blink-emoji";
            # spelling suggestions as completions
            spell = defaultSourcePluginOption "spell" "blink-cmp-spell" "blink-cmp-spell";
            # words from nearby files
            ripgrep = defaultSourcePluginOption "ripgrep" "blink-ripgrep-nvim" "blink-ripgrep";
          };
        };
        default = {};
        description = ''
          `blink.cmp` sources.

          Attribute names must be source names used in {option}`vim.autocomplete.blink-cmp.setupOpts.sources.default`.
        '';
      };

    friendly-snippets.enable = mkEnableOption "friendly-snippets for blink to source from automatically";
  };
}
