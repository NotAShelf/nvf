{
  config,
  lib,
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkDefault;
  cfg = config.vim.theme;
in {
  base16 = {
    setupOpts = {
      inherit (cfg) base16-colors;
    };
  };
  onedark = {
    setupOpts = {
      style = cfg.style ? "dark";
    };
    setup = _: ''
      -- OneDark theme
            require('onedark').load()
    '';
    styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];
  };

  tokyonight = {
    setupOpts = {
      inherit (cfg) transparent;
    };
    setup = {style ? "night", ...}: ''
      vim.cmd[[colorscheme tokyonight-${style}]]
    '';
    styles = ["day" "night" "storm" "moon"];
  };

  dracula = {
    setupOpts = {
      transparent_bg = cfg.transparent;
    };
    setup = _: ''
      require('dracula').load();
    '';
  };

  catppuccin = {
    setupOpts = {
      flavour = cfg.style ? "mocha";
      transparent_background = cfg.transparent;
      term_colors = mkDefault true;
      integrations = {
        nvimtree = {
          enabled = mkDefault true;
          transparent_panel = cfg.transparent;
          show_root = mkDefault true;
        };

        hop = mkDefault true;
        gitsigns = mkDefault true;
        telescope = mkDefault true;
        treesitter = mkDefault true;
        treesitter_context = mkDefault true;
        ts_rainbow = mkDefault true;
        fidget = mkDefault true;
        alpha = mkDefault true;
        leap = mkDefault true;
        markdown = mkDefault true;
        noice = mkDefault true;
        # nvim-notify
        notify = mkDefault true;
        which_key = mkDefault true;
        navic = {
          enabled = mkDefault true;
          # lualine will set backgound to mantle
          custom_bg = "NONE";
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
    setupOpts = {};
    setup = _: ''
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
    setupOpts = {
      transparent_mode = cfg.transparent;
      # add neovim terminal colors
      terminal_colors = mkDefault true;
      undercurl = mkDefault true;
      underline = mkDefault true;
      bold = mkDefault true;
      italic = {
        strings = mkDefault true;
        emphasis = mkDefault true;
        comments = mkDefault true;
        operators = mkDefault false;
        folds = mkDefault true;
      };
      strikethrough = mkDefault true;
      invert_selection = mkDefault false;
      invert_signs = mkDefault false;
      invert_tabline = mkDefault false;
      invert_intend_guides = mkDefault false;
      inverse = mkDefault true;
      contrast = "";
      palette_overrides = {};
      overrides = {};
      dim_inactive = mkDefault false;
    };
    setup = _: ''
      -- Gruvbox theme
      vim.o.background = "${cfg.style ? "dark"}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
  rose-pine = {
    setupOpts = {
      dark_variant = cfg.style ? "main";
      dim_inactive_windows = mkDefault false;
      extend_background_behind_borders = mkDefault true;

      enable = {
        terminal = mkDefault true;
        migrations = mkDefault true;
      };

      styles = {
        bold = mkDefault false;
        # I would like to add more options for this
        italic = mkDefault false;
        transparency = cfg.transparent;
      };
    };

    setup = _: ''
      vim.cmd("colorscheme rose-pine")
    '';
    styles = ["main" "moon" "dawn"];
  };
}
