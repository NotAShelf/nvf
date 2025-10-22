{
  config,
  lib,
}: let
  inherit (lib.strings) optionalString splitString;
  inherit (lib.attrsets) mapCartesianProduct;
  inherit (lib.lists) intersectLists;
  inherit (lib.trivial) warnIf;
  inherit (lib.nvim.lua) toLuaObject;
in {
  # FIXME: those all need to be converted to setupOpts format
  # or else we explode...
  base16 = {
    setup = setupOpts: ''
      -- Base16 theme
      require('base16-colorscheme').setup(${toLuaObject setupOpts})
    '';
  };

  mini-base16 = {
    setup = setupOpts: ''
      -- Base16 theme
      require('mini.base16').setup({
        palette = ${toLuaObject setupOpts}
      })
    '';
  };

  onedark = {
    styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];
    setup = setupOpts: ''
      -- OneDark theme
      require('onedark').setup(${toLuaObject setupOpts})
      require('onedark').load()
    '';
  };

  tokyonight = {
    styles = ["day" "night" "storm" "moon"];
    setup = setupOpts: ''
      require('tokyonight').setup(${toLuaObject setupOpts})
      vim.cmd[[colorscheme tokyonight-${setupOpts.style or "night"}]]
    '';
  };

  dracula = {
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["transparent"])
        // {
          transparent_bg = setupOpts.transparent or false;
        };
    in ''
      require('dracula').setup(${toLuaObject cleanedOpts});
      require('dracula').load();
    '';
  };

  catppuccin = {
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["style" "transparent"])
        // {
          flavour = setupOpts.style or "mocha";
          transparent_background = setupOpts.transparent or false;
          float = {
            transparent = setupOpts.transparent or false;
          };
          term_colors = true;
          integrations = {
            nvimtree = {
              enabled = true;
              transparent_panel = setupOpts.transparent or false;
              show_root = true;
            };

            hop = true;
            gitsigns = true;
            telescope = true;
            treesitter = true;
            treesitter_context = true;
            ts_rainbow = true;
            fidget = true;
            alpha = true;
            leap = true;
            lsp_saga = true;
            markdown = true;
            noice = true;
            notify = true; # nvim-notify
            which_key = true;
            navic = {
              enabled = true;
              custom_bg = "NONE"; # "lualine" will set background to mantle
            };
          };
        };
    in ''
      -- Catppuccin theme
      require('catppuccin').setup(${toLuaObject cleanedOpts})
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["auto" "latte" "frappe" "macchiato" "mocha"];
  };

  oxocarbon = {
    setup = setupOpts: let
      style = setupOpts.style or "dark";
      style' = warnIf (style == "light") "oxocarbon: light theme is not well-supported" style;
      transparent = setupOpts.transparent or false;
    in ''
      require('oxocarbon')
      vim.opt.background = "${style'}"
      vim.cmd.colorscheme "oxocarbon"
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
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["transparent" "style"])
        // {
          terminal_colors = true; # add neovim terminal colors
          undercurl = true;
          underline = true;
          bold = true;
          italic = {
            strings = true;
            emphasis = true;
            comments = true;
            operators = false;
            folds = true;
          };
          strikethrough = true;
          invert_selection = false;
          invert_signs = false;
          invert_tabline = false;
          invert_intend_guides = false;
          inverse = true;
          contrast = "";
          palette_overrides = {};
          overrides = {};
          dim_inactive = false;
          transparent_mode = setupOpts.transparent or false;
        };
      style = setupOpts.style or "dark";
    in ''
          styles = ["dark" "light"];
      -- Gruvbox theme
      require("gruvbox").setup(${toLuaObject cleanedOpts})
      vim.o.background = "${style}"
      vim.cmd("colorscheme gruvbox")
    '';
  };

  rose-pine = {
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["style" "transparent"])
        // {
          dark_variant = setupOpts.style or "main"; # main, moon, or dawn
          dim_inactive_windows = false;
          extend_background_behind_borders = true;

          enable = {
            terminal = true;
            migrations = true;
          };

          styles = {
            bold = false;
            italic = false; # I would like to add more options for this
            transparency = setupOpts.transparent or false;
          };
        };
    in ''
      require("rose-pine").setup(${toLuaObject cleanedOpts})
      vim.cmd("colorscheme rose-pine")
    '';
    styles = ["main" "moon" "dawn"];
  };

  nord = {
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["transparent"])
        // {
          transparent = setupOpts.transparent or false;
          search = "vscode"; # [vim|vscode]
        };
    in ''
      require("nord").setup(${toLuaObject cleanedOpts})
      vim.cmd.colorscheme("nord")
    '';
  };

  github = {
    styles = ["dark" "light" "dark_dimmed" "dark_default" "light_default" "dark_high_contrast" "light_high_contrast" "dark_colorblind" "light_colorblind" "dark_tritanopia" "light_tritanopia"];
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["transparent" "style"])
        // {
          options = {
            transparent = setupOpts.transparent or false;
          };
        };
      style = setupOpts.style or "dark";
    in ''
      require('github-theme').setup(${toLuaObject cleanedOpts})
      vim.cmd[[colorscheme github_${style}]]
    '';
  };

  solarized = let
    backgrounds = ["light" "dark"];
    palettes = ["solarized" "selenized"];
    variants = ["spring" "summer" "autumn" "winter"];
  in {
    setup = setupOpts: let
      style = setupOpts.style or "";
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
      baseSetup =
        {
          transparent = {
            enabled = setupOpts.transparent or false;
          };
        }
        // (removeAttrs setupOpts ["style" "transparent"]);
      finalSetup =
        baseSetup
        // (
          if palette != null
          then {palette = palette;}
          else {}
        )
        // (
          if variant != null
          then {variant = variant;}
          else {}
        );
    in ''
      -- Solarized theme
      require('solarized').setup(${toLuaObject finalSetup})
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
    setup = setupOpts: let
      cleanedOpts =
        (removeAttrs setupOpts ["transparent"])
        // {
          transparent = setupOpts.transparent or false;
          styles = {
            comments = {italic = false;};
            keywords = {italic = false;};
          };
        };
    in ''
      require("solarized-osaka").setup(${toLuaObject cleanedOpts})
      vim.cmd.colorscheme("solarized-osaka")
    '';
  };

  everforest = {
    styles = ["hard" "medium" "soft"];
    setup = setupOpts: let
      style = setupOpts.style or "medium";
      transparent = setupOpts.transparent or false;
    in ''
      vim.g.everforest_background = "${style}"
      vim.g.everforest_transparent_background = ${
        if transparent
        then "1"
        else "0"
      }

      vim.cmd.colorscheme("everforest")
    '';
  };
}
