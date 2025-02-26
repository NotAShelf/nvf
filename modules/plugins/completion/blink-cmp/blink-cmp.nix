{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalMD;
  inherit (lib.types) listOf str either attrsOf submodule enum anything int nullOr;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline pluginType;
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

        providers = mkOption {
          type = attrsOf providerType;
          default = {};
          description = "Settings for completion providers";
        };

        transform_items = mkOption {
          type = nullOr luaInline;
          default = mkLuaInline "function(_, items) return items end";
          defaultText = ''
            Our default does nothing. If you want blink.cmp's default, which
            lowers the score for snippets, set this option to null.
          '';
          description = ''
            Function to use when transforming the items before they're returned
            for all providers.
          '';
        };
      };

      cmdline = {
        sources = mkOption {
          type = nullOr (listOf str);
          default = [];
          description = "List of sources to enable for cmdline. Null means use default source list.";
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

      fuzzy = {
        prebuilt_binaries = {
          download = mkBool false ''
            Auto-downloads prebuilt binaries. Do not enable, it doesn't work on nix
          '';
        };
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

    sourcePlugins = let
      sourcePluginType = submodule {
        options = {
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
          enable = mkEnableOption "this source";
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
