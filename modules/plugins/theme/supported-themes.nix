{
  config,
  lib,
}: let
  inherit (lib.strings) hasPrefix optionalString;
  inherit (lib.attrsets) listToAttrs;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.types) bool str;
  inherit (lib.nvim.types) hexColor mkPluginSetupOption;
  cfg = config.vim.theme;

  mkEnableOption' = name: mkEnableOption name // {default = true;};
  numbers = ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F"];
  base16Options = listToAttrs (map (n: {
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
    numbers);
in {
  base16 = {
    setupOpts = mkPluginSetupOption "base16" base16Options;
    setup = "";
  };

  onedark = {
    setupOpts = mkPluginSetupOption "onedark" {
      style = mkOption {
        type = str;
        default = cfg.style;
        internal = true;
      };
    };
    setup = ''
      -- OneDark theme
      require('onedark').load()
    '';
    styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];
  };

  tokyonight = {
    setupOpts = mkPluginSetupOption "tokyonight" {
      transparent = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
    };
    setup = ''
      vim.cmd[[colorscheme tokyonight-${cfg.style}]]
    '';
    styles = ["night" "day" "storm" "moon"];
  };

  dracula = {
    setupOpts = mkPluginSetupOption "dracula" {
      transparent_bg = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
    };
    setup = ''
      require('dracula').load();
    '';
  };

  catppuccin = {
    setupOpts = mkPluginSetupOption "catppuccin" {
      flavour = mkOption {
        type = str;
        default = cfg.style;
        # internal = true;
      };
      transparent_background = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
      term_colors = mkEnableOption' "term_colors";
      integrations = {
        nvimtree = {
          enabled = mkEnableOption' "enabled";
          transparent_panel = mkOption {
            type = bool;
            default = cfg.transparent;
          };
          show_root = mkEnableOption' "show_root";
        };

        hop = mkEnableOption' "hop";
        gitsigns = mkEnableOption' "gitsigns";
        telescope = mkEnableOption' "telescope";
        treesitter = mkEnableOption' "treesitter";
        treesitter_context = mkEnableOption' "treesitter_context";
        ts_rainbow = mkEnableOption' "ts_rainbow";
        fidget = mkEnableOption' "fidget";
        alpha = mkEnableOption' "alpha";
        leap = mkEnableOption' "leap";
        markdown = mkEnableOption' "markdown";
        noice = mkEnableOption' "noice";
        # nvim-notify
        notify = mkEnableOption' "notify";
        which_key = mkEnableOption' "which_key";
        navic = {
          enabled = mkEnableOption' "enabled";
          # lualine will set backgound to mantle
          custom_bg = mkOption {
            type = str;
            default = "NONE";
          };
        };
      };
    };
    setup = ''
      -- Catppuccin theme
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["mocha" "latte" "frappe" "macchiato"];
  };

  oxocarbon = {
    setupOpts = {};
    setup = ''
       require('oxocarbon')
       vim.opt.background = "${cfg.style}"
       vim.cmd.colorscheme = "oxocarbon"
      ${optionalString cfg.transparent ''
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        ${optionalString config.vim.filetree.nvimTree.enable ''
          vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
        ''}
      ''}
    '';
    styles = ["dark" "light"];
  };

  gruvbox = {
    setupOpts = mkPluginSetupOption "gruvbox" {
      transparent_mode = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
      # transparent_mode = cfg.transparent;
      # add neovim terminal colors
      terminal_colors = mkEnableOption' "terminal_colors";
      undercurl = mkEnableOption' "undercurls";
      underline = mkEnableOption' "underline";
      bold = mkEnableOption' "bold";
      italic = {
        strings = mkEnableOption' "strings";
        emphasis = mkEnableOption' "emphasis";
        comments = mkEnableOption' "comments";
        operators = mkEnableOption "operators";
        folds = mkEnableOption' "folds";
      };
      strikethrough = mkEnableOption' "strikethrough";
      invert_selection = mkEnableOption "invert_selection";
      invert_signs = mkEnableOption "invert_signs";
      invert_tabline = mkEnableOption "invert_tabline";
      invert_intend_guides = mkEnableOption "invert_intend_guides";
      inverse = mkEnableOption' "inverse";
      contrast = mkOption {
        type = str;
        default = "";
      };
      # TODO: fix these
      # palette_overrides = mkLuaInline "{}";
      # overrides = mkLuaInline "{}";
      dim_inactive = mkEnableOption "dim_inactive";
    };
    setup = ''
      -- Gruvbox theme
      vim.o.background = "${cfg.style}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
  rose-pine = {
    setupOpts = mkPluginSetupOption "rose-pine" {
      dark_variant = mkOption {
        type = str;
        default = cfg.style;
        internal = true;
      };
      dim_inactive_windows = mkEnableOption "dim_inactive_windows";
      extend_background_behind_borders = mkEnableOption' "extend_background_behind_borders";

      enable = {
        terminal = mkEnableOption' "terminal";
        migrations = mkEnableOption' "migrations";
      };

      styles = {
        bold = mkEnableOption "bold";
        # I would like to add more options for this
        italic = mkEnableOption "italic";
        transparency = mkOption {
          type = bool;
          default = cfg.transparent;
          internal = true;
        };
      };
    };

    setup = ''
      vim.cmd("colorscheme rose-pine")
    '';
    styles = ["main" "moon" "dawn"];
  };
}
