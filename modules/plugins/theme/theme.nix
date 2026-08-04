{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) bool lines enum submodule attrsOf nullOr;
  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (lib.strings) hasPrefix;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.types) hexColor mkPluginSetupOption;

  cfg = config.vim.theme;
  supportedThemes = import ./supported-themes.nix {
    inherit lib config;
  };

  numbers = ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F"];
  base16Options =
    mapListToAttrs (n: {
      name = "base0${n}";
      value = mkOption {
        description = "The base0${n} color to use";
        type = hexColor;
        apply = v:
          if hasPrefix "#" v
          then v
          else "#${v}";
      };
    })
    numbers;

  # Get all enabled themes
  enabledThemes = filterAttrs (_: themeCfg: themeCfg.enable) cfg.themes;
  nonDefaultThemes = filterAttrs (name: _: name != cfg.default) enabledThemes;
  newConfigUsed = enabledThemes != {};
  catppuccinIntegrationNames = [
    "aerial"
    "alpha"
    "blink_cmp"
    "bufferline"
    "cmp"
    "dap"
    "dap_ui"
    "dashboard"
    "diffview"
    "fidget"
    "flash"
    "gitsigns"
    "grug_far"
    "harpoon"
    "hop"
    "indent_blankline"
    "leap"
    "lsp_saga"
    "lsp_trouble"
    "mini"
    "neogit"
    "neotree"
    "navic"
    "noice"
    "notify"
    "nvim_surround"
    "nvimtree"
    "telescope"
    "treesitter"
    "treesitter_context"
    "ufo"
    "which_key"
  ];
  catppuccinIntegrations = filterAttrs (name: integration: builtins.elem name catppuccinIntegrationNames && integration.enable) cfg.catppuccin.integrations;
  themeSetupOpts = name: themeCfg:
    if name == "catppuccin"
    then
      themeCfg.setupOpts
      // lib.optionalAttrs (!(themeCfg.setupOpts ? default_integrations)) {
        default_integrations = false;
      }
      // lib.optionalAttrs (catppuccinIntegrations != {}) {
        integrations = (themeCfg.setupOpts.integrations or {}) // lib.mapAttrs (_: _: true) catppuccinIntegrations;
      }
    else themeCfg.setupOpts;

  # Get the default theme configuration
  defaultTheme =
    if cfg.default != null && enabledThemes ? ${cfg.default}
    then enabledThemes.${cfg.default}
    else null;
in {
  options.vim.theme = {
    enable = mkEnableOption "theming";

    default = mkOption {
      type = nullOr (enum (attrNames supportedThemes));
      default = null;
      description = ''
        The default theme to load in the built configuration. While this option
        is set and the matching theme is enabled in {option}`vim.theme.themes`
        the theme specified by this option will be set automatically as the
        default theme. If `null`, the user is responsible for setting their
        preferred theme either by explicitly setting this option, or using Lua.
      '';
    };

    themes = let
      themeType = {name, ...}: {
        options = {
          enable = mkEnableOption "the ${name} theme";
          setupOpts = mkPluginSetupOption name {};
        };
      };
    in
      mkOption {
        type = attrsOf (submodule themeType);
        default = {};
        example = {
          tokyonight = {
            enable = true;
            setupOpts = {
              style = "night";
              transparent = true;
            };
          };

          catppuccin = {
            enable = true;
            setupOpts = {
              flavour = "mocha";
              transparent_background = true;
              integrations = {
                nvimtree = {
                  enabled = true;
                  transparent_panel = true;
                };
                telescope = true;
                treesitter = true;
              };
            };
          };

          onedark = {
            enable = false; # Available but not loaded
            setupOpts = {
              style = "darker";
              transparent = false;
            };
          };
        };

        description = ''
          Configure multiple themes at once. All enabled themes are loaded in
          the configuration. While {option}`vim.theme.default` is set, that
          theme is selected automatically.
        '';
      };

    catppuccin.integrations =
      {
        lualine = mkEnableOption "the Catppuccin lualine integration";
      }
      // mapListToAttrs (name: {
        inherit name;
        value = mkEnableOption "the Catppuccin ${name} integration";
      })
      catppuccinIntegrationNames;

    # Legacy options for backwards compatibility
    # FIXME: this could have been handled directly with mkRenamedOptionModule
    # or similar, but I found it too difficult to handle it gracefully. Those
    # are kept here **with a warning** but without completely removing the
    # relevant options. Worth completely dropping in the future.
    name = mkOption {
      type = enum (attrNames supportedThemes);
      default = "onedark";
      description = ''
        Supported themes can be found in {file}`supportedThemes.nix`.
        Setting the theme to "base16" enables base16 theming and
        requires all of the colors in {option}`vim.theme.base16-colors` to be set.
      '';
    };

    style = mkOption {
      type = enum supportedThemes.${cfg.name}.styles;
      default = builtins.head supportedThemes.${cfg.name}.styles;
      description = "Specific style for theme if it supports it";
    };

    transparent = mkOption {
      type = bool;
      default = false;
      description = "Whether or not transparency should be enabled. Has no effect for themes that do not support transparency";
    };

    base16-colors = base16Options;

    extraConfig = mkOption {
      type = lines;
      default = "";
      description = "Additional Lua configuration to add before setup";
    };
  };

  config =
    {
      assertions = [
        {
          assertion = !cfg.enable -> cfg.default == null;
          message = "vim.theme.default requires vim.theme.enable.";
        }
        {
          assertion = cfg.default == null || (enabledThemes ? ${cfg.default});
          message = "vim.theme.default must name an enabled theme.";
        }
      ];
    }
    // mkIf cfg.enable {
      vim = {
        startPlugins =
          attrNames enabledThemes
          ++ lib.optional (!newConfigUsed) cfg.name;

        luaConfigRC.theme = entryBefore ["pluginConfigs" "lazyConfigs"] ''
          -- Theme configurations
          ${cfg.extraConfig}

          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
              themeName: themeCfg: ''
                -- Setup ${themeName} theme
                ${supportedThemes.${themeName}.setup (themeSetupOpts themeName themeCfg)}
              ''
            )
            nonDefaultThemes)}

          ${lib.optionalString (!newConfigUsed) (supportedThemes.${cfg.name}.setup (
            {
              inherit (cfg) style transparent;
            }
            // lib.optionalAttrs (cfg.name == "base16" || cfg.name == "mini-base16") {
              inherit (cfg) base16-colors;
            }
          ))}

          ${lib.optionalString (defaultTheme != null) (supportedThemes.${cfg.default}.setup (themeSetupOpts cfg.default defaultTheme))}
        '';
      };

      warnings = let
        legacyUsed =
          cfg.name
          != "onedark"
          || cfg.style != builtins.head supportedThemes.${cfg.name}.styles
          || cfg.transparent
          || cfg.extraConfig != "";
      in
        mkIf (legacyUsed && !newConfigUsed) [
          ''
            The theming module has been refactored to allow more powerful configurations  and multiple theme setups
            through the module system. This warning indicates that you are using the legacy API and have not
            yet used any of the new APIs. Please migrate your configuration to 'vim.theme.themes' API.

            Refer to the documentation for more details.
          ''
        ];
    };
}
