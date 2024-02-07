{lib}: {
  onedark = {
    setup = {
      style ? "dark",
      transparent,
    }: ''
      -- OneDark theme
      require('onedark').setup {
        style = "${style}"
      }
      require('onedark').load()
    '';
    styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];
  };

  tokyonight = {
    setup = {
      style ? "night",
      transparent,
    }: ''
      require('tokyonight').setup {
        transparent = ${lib.boolToString transparent};
      }
      vim.cmd[[colorscheme tokyonight-${style}]]
    '';
    styles = ["day" "night" "storm" "moon"];
  };

  dracula = {
    setup = {
      style ? null,
      transparent,
    }: ''
      require('dracula').setup({
        transparent_bg = ${lib.boolToString transparent},
      });
      require('dracula').load();
    '';
  };

  catppuccin = {
    setup = {
      style ? "mocha",
      transparent ? false,
    }: ''
      -- Catppuccin theme
      require('catppuccin').setup {
        flavour = "${style}",
        transparent_background = ${lib.boolToString transparent},
        integrations = {
      	  nvimtree = {
      		  enabled = true,
      		  transparent_panel = ${lib.boolToString transparent},
      		  show_root = true,
      	  },

          hop = true,
      	  gitsigns = true,
      	  telescope = true,
      	  treesitter = true,
      	  ts_rainbow = true,
          fidget = true,
          alpha = true,
          leap = true,
          markdown = true,
          noice = true,
          notify = true, -- nvim-notify
          which_key = true,
          navic = {
            enabled = false,
            custom_bg = "NONE", -- "lualine" will set background to mantle
          },
        },
      }
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["latte" "frappe" "macchiato" "mocha"];
  };

  oxocarbon = {
    setup = {
      style ? "dark",
      transparent ? false,
    }: let
      style' =
        lib.warnIf (style == "light") "oxocarbon: light theme is not well-supported" style;
    in ''
      require('oxocarbon')
      vim.opt.background = "${style'}"
      vim.cmd.colorscheme = "oxocarbon"
    '';
    styles = ["dark" "light"];
  };

  gruvbox = {
    setup = {
      style ? "dark",
      transparent ? false,
    }: ''
      -- Gruvbox theme
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = ${lib.boolToString transparent},
      })
      vim.o.background = "${style}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
}
