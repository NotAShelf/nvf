{
  config,
  lib,
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  cfg = config.vim.theme;

  mkEnableOption' = name: mkEnableOption name // {default = true;};
  # mkEnableOption' = name: mkEnableOption name;
in {
  base16 = {
    setupOpts = mkPluginSetupOption "base16" {
      inherit (cfg) base16-colors;
    };
  };
  onedark = {
    setupOpts = mkPluginSetupOption "onedark" {
      style = mkOption {
        type = str;
        default = "dark";
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
      vim.cmd[[colorscheme tokyonight-${cfg.style ? "night"}]]
    '';
    styles = ["day" "night" "storm" "moon"];
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
      # flavour = cfg.style ? "mocha";
      flavour = mkOption {
        type = str;
        default = cfg.style ? "mocha";
        internal = true;
      };
      transparent_background = mkOption {
        type = bool;
        default = cfg.transparency;
        internal = true;
      };
      term_colors = mkEnableOption' "term_colors";
      integrations = {
        nvimtree = {
          enabled = mkEnableOption' "enabled";
          transparent_panel = mkOption {
            type = bool;
            default = cfg.transparency;
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
        navic = mkOption {
          enabled = mkEnableOption' "enabled";
          # lualine will set backgound to mantle
          custom_bg = mkOption {
            type = str;
            default = "NONE";
          };
        };
      };
    };
    setup = _: ''
      -- Catppuccin theme
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["latte" "frappe" "macchiato" "mocha"];
  };

  oxocarbon = {
    setupOpts = mkPluginSetupOption "oxocarbon" {};
    setup = ''
       require('oxocarbon')
       vim.opt.background = "${cfg.style ? "dark"}"
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
      transparent_mode = cfg.transparent;
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
      contrast = "";
      palette_overrides = {};
      overrides = {};
      dim_inactive = mkEnableOption "dim_inactive";
    };
    setup = ''
      -- Gruvbox theme
      vim.o.background = "${cfg.style ? "dark"}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
  rose-pine = {
    setupOpts = mkPluginSetupOption "rose-pine" {
      dark_variant = mkOption {
        type = str;
        style = cfg.style ? "main";
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
