{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) attrNames;
  inherit (lib.strings) hasPrefix;
  inherit (lib.types) bool lines enum;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.types) hexColor;

  cfg = config.vim.theme;
  supportedThemes = import ./supported-themes.nix {
    inherit lib config;
  };

  base16 = ["00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "0A" "0B" "0C" "0D" "0E" "0F"];
  base24 = ["00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "0A" "0B" "0C" "0D" "0E" "0F" "10" "11" "12" "13" "14" "15" "16" "17"];
  determineSchemeSystem =
    if config.vim.theme.tinted-options.scheme-system == "base24"
    then base24
    else base16;
  tinted-colors =
    mapListToAttrs (n: {
      name = "base${n}";
      value = mkOption {
        description = "The base${n} color to use";
        type = hexColor;
        apply = v:
          if hasPrefix "#" v
          then v
          else "#${v}";
      };
    })
    determineSchemeSystem;
  tinted-options = {
    colors = tinted-colors;
    scheme-system = mkOption {
      type = bool;
      default = true;
      description = "Scheme system for theme (eg 'base16')";
    };
    supports = {
      tinty = mkOption {
        type = bool;
        default = false;
        description = "Automatically load the colorscheme set by Tinty CLI (https://github.com/tinted-theming/tinty)";
      };
      live_reload = mkOption {
        type = bool;
        default = false;
        description = "Automatically reload with a new theme when applied by Tinty CLI (https://github.com/tinted-theming/tinty)";
      };
      tinted_shell = mkOption {
        type = bool;
        default = false;
        description = "Automatically load the colorscheme set by tinted-shell (tinted-theming/tinted-shell)";
      };
    };

    highlights = {
      telescope = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for Telescope";
      };
      telescope_borders = mkOption {
        type = bool;
        default = false;
        description = "Set highlights for Telescope borders";
      };
      indentblankline = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for indentblankline";
      };
      notify = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for notify";
      };
      ts_rainbow = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for ts_rainbow";
      };
      cmp = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for cmp";
      };
      illuminate = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for illuminate";
      };
      lsp_semantic = mkOption {
        type = bool;
        default = true;
        description = "Set LSP semantic highlights";
      };
      mini_completion = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for mini.completion";
      };
      dapui = mkOption {
        type = bool;
        default = true;
        description = "Set highlights for dapui";
      };
    };
  };
in {
  options.vim.theme = {
    inherit tinted-options;

    enable = mkOption {
      type = bool;
      description = "Enable theming";
    };
    name = mkOption {
      type = enum (attrNames supportedThemes);
      description = ''
        Supported themes can be found in {file}`supportedThemes.nix`. Setting
        the theme to "tinted-theming" enables base16 and base24 theming,
        requires all of the colors in {option}`vim.theme.tinted-colors` to be
        set and adds all of the "tinted-nvim" colorschemes.
      '';
    };

    style = mkOption {
      type = enum supportedThemes.${cfg.name}.styles;
      description = "Specific style for theme if it supports it";
    };
    transparent = mkOption {
      type = bool;
      default = false;
      description = "Whether or not transparency should be enabled. Has no effect for themes that do not support transparency";
    };

    extraConfig = mkOption {
      type = lines;
      description = "Additional lua configuration to add before setup";
    };
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins = [cfg.name];
      luaConfigRC.theme = entryBefore ["pluginConfigs" "lazyConfigs"] ''
        ${cfg.extraConfig}
        ${supportedThemes.${cfg.name}.setup {inherit (cfg) style transparent tinted-options;}}
      '';
    };
  };
}
