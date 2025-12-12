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
  inherit (lib.nvim.lua) toLuaObject;

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

  # Get the default theme configuration
  defaultTheme =
    if cfg.default != null && enabledThemes ? ${cfg.default}
    then enabledThemes.${cfg.default}
    else null;
in {
  options.vim.theme = {
    enable = mkEnableOption "theming";

    default = mkOption {
      type = nullOr enum (attrNames supportedThemes);
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
          New theme configuration option for v0.8 and above. This system allows
          you to set multiple themes at once, where **all** enabled themes will
          be loaded in the configuration. While {option}`vim.theme.default` is
          set, the default theme will be set automatically in the configuration.
        '';
      };

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

        ::: {.note}

        Legacy option: use vim.theme.themes.<name>.enable = true and vim.theme.default = "<name>" instead.

        :::

      '';
    };

    style = mkOption {
      type = enum supportedThemes.${cfg.name}.styles;
      default = builtins.head supportedThemes.${cfg.name}.styles;
      description = "Legacy option: use `vim.theme.themes.<name>.setupOpts.style` instead";
    };

    transparent = mkOption {
      type = bool;
      default = false;
      description = "Legacy option: use `vim.theme.themes.<name>.setupOpts.transparent` instead";
    };

    base16-colors = base16Options;

    extraConfig = mkOption {
      type = lines;
      default = "";
      description = "Additional Lua configuration to add before setup";
    };
  };

  config = mkIf cfg.enable {
    vim = {
      # Include plugins for all enabled themes
      startPlugins = attrNames enabledThemes;

      luaConfigRC.theme = entryBefore ["pluginConfigs" "lazyConfigs"] ''
        -- Theme configurations
        ${cfg.extraConfig}

        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
            # FIXME: this only works when the plugin accepts setupOpts. We need to
            # either check for this in Lua, or list the plugins that support the
            # setup table instead of using globals.
            themeName: themeCfg: ''
              -- Setup ${themeName} theme
              require('${themeName}').setup(${toLuaObject themeCfg.setupOpts})
            ''
          )
          enabledThemes)}

        ${lib.optionalString (defaultTheme != null) ''
          -- Load default theme:
          -- ${cfg.default}
          vim.cmd.colorscheme "${cfg.default}"
        ''}
      '';
    };

    # We'd like to warn when the user is using a completely legacy configuration
    warnings = let
      # FIXME: what
      legacyUsed = cfg.style != builtins.head supportedThemes.${cfg.name}.styles || !cfg.transparent;
      newConfigUsed = builtins.length (attrNames enabledThemes) > 0;
    in
      mkIf (legacyUsed && !newConfigUsed) [
        ''
          The theming module has been refactored to allow more powerful configurations  and multiple theme setups
          through the module system in v0.8. This warning indicates that you are using the legacy API and have not
          yet used any of the new APIs. Please migrate your configuration to 'vim.theme.themes' API.

          Refer to the documentation for more details.
        ''
      ];
  };
}
