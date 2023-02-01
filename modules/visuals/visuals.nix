{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.visuals;
in {
  options.vim.visuals = {
    enable = mkOption {
      type = types.bool;
      description = "visual enhancements";
    };

    nvimWebDevicons.enable = mkOption {
      type = types.bool;
      description = "enable dev icons. required for certain plugins [nvim-web-devicons]";
    };

    lspkind.enable = mkOption {
      type = types.bool;
      description = "enable vscode-like pictograms for lsp [lspkind]";
    };

    cursorWordline = {
      enable = mkOption {
        type = types.bool;
        description = "enable word and delayed line highlight [nvim-cursorline]";
      };

      lineTimeout = mkOption {
        type = types.int;
        description = "time in milliseconds for cursorline to appear";
      };
    };

    indentBlankline = {
      enable = mkOption {
        type = types.bool;
        description = "enable indentation guides [indent-blankline]";
      };

      listChar = mkOption {
        type = types.str;
        description = "Character for indentation line";
      };

      fillChar = mkOption {
        type = types.str;
        description = "Character to fill indents";
      };

      eolChar = mkOption {
        type = types.str;
        description = "Character at end of line";
      };

      showCurrContext = mkOption {
        type = types.bool;
        description = "Highlight current context from treesitter";
      };
    };
  };

  config =
    mkIf cfg.enable
    {
      vim.startPlugins = [
        (
          if cfg.nvimWebDevicons.enable
          then "nvim-web-devicons"
          else null
        )
        (
          if cfg.lspkind.enable
          then "lspkind"
          else null
        )
        (
          if cfg.cursorWordline.enable
          then "nvim-cursorline"
          else null
        )
        (
          if cfg.indentBlankline.enable
          then "indent-blankline"
          else null
        )
      ];

      vim.luaConfigRC.visuals = nvim.dag.entryAnywhere ''
        ${
          if cfg.lspkind.enable
          then "require'lspkind'.init()"
          else ""
        }
        ${
          if cfg.indentBlankline.enable
          then ''
            -- highlight error: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
            vim.wo.colorcolumn = "99999"
            vim.opt.list = true


            ${
              if cfg.indentBlankline.eolChar == ""
              then ""
              else ''vim.opt.listchars:append({ eol = "${cfg.indentBlankline.eolChar}" })''
            }

            ${
              if cfg.indentBlankline.fillChar == ""
              then ""
              else ''vim.opt.listchars:append({ space = "${cfg.indentBlankline.fillChar}"})''
            }

            require("indent_blankline").setup {
              char = "${cfg.indentBlankline.listChar}",
              show_current_context = ${boolToString cfg.indentBlankline.showCurrContext},
              show_end_of_line = true,
            }
          ''
          else ""
        }

        ${
          if cfg.cursorWordline.enable
          then "vim.g.cursorline_timeout = ${toString cfg.cursorWordline.lineTimeout}"
          else ""
        }
      '';
    };
}
