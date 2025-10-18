{
  config,
  lib,
}: let
  inherit (lib.strings) optionalString splitString;
  inherit (lib.attrsets) mapCartesianProduct;
  inherit (lib.lists) intersectLists;
  inherit (lib.trivial) boolToString warnIf;
  inherit (lib.nvim.lua) toLuaObject;
in {
  base16 = {
    setup = {base16-colors, ...}: ''
      -- Base16 theme
      require('base16-colorscheme').setup(${toLuaObject base16-colors})
    '';
  };
  mini-base16 = {
    setup = {base16-colors, ...}: ''
      -- Base16 theme
      require('mini.base16').setup({
        palette = ${toLuaObject base16-colors}
      })
    '';
  };
  onedark = {
    setup = {
      style ? "dark",
      transparent,
      ...
    }: ''
      -- OneDark theme
      require('onedark').setup {
        transparent = ${boolToString transparent},
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
      ...
    }: ''
      require('tokyonight').setup {
        transparent = ${boolToString transparent};
      }
      vim.cmd[[colorscheme tokyonight-${style}]]
    '';
    styles = ["day" "night" "storm" "moon"];
  };

  dracula = {
    setup = {transparent, ...}: ''
      require('dracula').setup({
        transparent_bg = ${boolToString transparent},
      });
      require('dracula').load();
    '';
  };

  catppuccin = {
    setup = {
      style ? "mocha",
      transparent ? false,
      ...
    }: ''
      -- Catppuccin theme
      require('catppuccin').setup {
        flavour = "${style}",
        transparent_background = ${boolToString transparent},
        float = {
          transparent = ${boolToString transparent},
        },
        term_colors = true,
        integrations = {
          nvimtree = {
            enabled = true,
            transparent_panel = ${boolToString transparent},
            show_root = true,
          },

          hop = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          ts_rainbow = true,
          fidget = true,
          alpha = true,
          leap = true,
          lsp_saga = true,
          markdown = true,
          noice = true,
          notify = true, -- nvim-notify
          which_key = true,
          navic = {
            enabled = true,
            custom_bg = "NONE", -- "lualine" will set background to mantle
          },
        },
      }
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["auto" "latte" "frappe" "macchiato" "mocha"];
  };

  oxocarbon = {
    setup = {
      style ? "dark",
      transparent ? false,
      ...
    }: let
      style' =
        warnIf (style == "light") "oxocarbon: light theme is not well-supported" style;
    in ''
      require('oxocarbon')
      vim.opt.background = "${style'}"
      vim.cmd.colorscheme = "oxocarbon"
      ${optionalString transparent ''
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
    setup = {
      style ? "dark",
      transparent ? false,
      ...
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
        transparent_mode = ${boolToString transparent},
      })
      vim.o.background = "${style}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
  rose-pine = {
    setup = {
      style ? "main",
      transparent ? false,
      ...
    }: ''
      require("rose-pine").setup({
        dark_variant = "${style}", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          migrations = true,
        },

        styles = {
          bold = false,
          italic = false, -- I would like to add more options for this
          transparency = ${boolToString transparent},
        },
      })

      vim.cmd("colorscheme rose-pine")
    '';
    styles = ["main" "moon" "dawn"];
  };
  nord = {
    setup = {transparent ? false, ...}: ''
      require("nord").setup({
        transparent = ${boolToString transparent},
        search = "vscode", -- [vim|vscode]
      })

      vim.cmd.colorscheme("nord")
    '';
  };
  github = {
    setup = {
      style ? "dark",
      transparent ? false,
      ...
    }: ''
      require('github-theme').setup({
        options = {
          transparent = ${boolToString transparent},
        },
      })

      vim.cmd[[colorscheme github_${style}]]
    '';
    styles = ["dark" "light" "dark_dimmed" "dark_default" "light_default" "dark_high_contrast" "light_high_contrast" "dark_colorblind" "light_colorblind" "dark_tritanopia" "light_tritanopia"];
  };

  solarized = let
    backgrounds = ["light" "dark"];
    palettes = ["solarized" "selenized"];
    variants = ["spring" "summer" "autumn" "winter"];
  in {
    setup = {
      style ? "", # use plugin defaults
      transparent ? false,
      ...
    }: let
      parts = splitString "-" style;
      detect = list: let
        intersection = intersectLists parts list;
      in
        if intersection == []
        then null
        else builtins.head intersection;
      background = detect backgrounds;
      palette = detect palettes;
      variant = detect variants;
    in ''
      -- Solarized theme
      require('solarized').setup {
        transparent = {
          enabled = ${boolToString transparent},
        },
        ${optionalString (palette != null) ''palette = "${palette}",''}
        ${optionalString (variant != null) ''variant = "${variant}",''}
      }
      ${optionalString (background != null) ''vim.opt.background = "${background}"''}
      vim.cmd.colorscheme "solarized"
    '';
    styles = let
      joinWithDashes = parts: lib.concatStringsSep "-" (lib.filter (s: s != "") parts);
      combinations = mapCartesianProduct ({
        bg,
        pal,
        var,
      }:
        joinWithDashes [bg pal var]) {
        bg = [""] ++ backgrounds;
        pal = [""] ++ palettes;
        var = [""] ++ variants;
      };
    in
      lib.filter (s: s != "") combinations;
  };

  solarized-osaka = {
    setup = {transparent ? false, ...}: ''
      require("solarized-osaka").setup({
        transparent = ${boolToString transparent},
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
        }
      })

      vim.cmd.colorscheme("solarized-osaka")
    '';
  };

  everforest = {
    setup = {
      style ? "medium",
      transparent ? false,
      ...
    }: ''
      vim.g.everforest_background = "${style}"
      vim.g.everforest_transparent_background = ${
        if transparent
        then "1"
        else "0"
      }

      vim.cmd.colorscheme("everforest")
    '';

    styles = ["hard" "medium" "soft"];
  };

  mellow = {
    setup = {transparent ? false, ...}: ''
      -- Mellow configuration
      vim.g.mellow_transparent = ${boolToString transparent}

      vim.cmd.colorscheme("mellow")
    '';
  };
}
