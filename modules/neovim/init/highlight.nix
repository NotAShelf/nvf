{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr attrsOf listOf submodule bool ints str enum;
  inherit (lib.strings) concatLines;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.nvim.dag) entryBetween;
  inherit (lib.nvim.lua) toLuaObject;

  mkColorOption = target:
    mkOption {
      type = nullOr str;
      default = null;
      example = "#ebdbb2";
      description = ''
        The ${target} color to use. Written as color name or hex "#RRGGBB".
      '';
    };

  mkBoolOption = name:
    mkOption {
      type = nullOr bool;
      default = null;
      example = false;
      description = "Whether to enable ${name}";
    };

  cfg = config.vim.highlight;
in {
  options.vim.highlight = mkOption {
    type = attrsOf (submodule {
      # See :h nvim_set_hl
      options = {
        bg = mkColorOption "background";
        fg = mkColorOption "foreground";
        sp = mkColorOption "special";
        blend = mkOption {
          type = nullOr (ints.between 0 100);
          default = null;
          description = "Blend as an integer between 0 and 100";
        };
        bold = mkBoolOption "bold";
        standout = mkBoolOption "standout";
        underline = mkBoolOption "underline";
        undercurl = mkBoolOption "undercurl";
        underdouble = mkBoolOption "underdouble";
        underdotted = mkBoolOption "underdotted";
        underdashed = mkBoolOption "underdashed";
        strikethrough = mkBoolOption "strikethrough";
        italic = mkBoolOption "italic";
        reverse = mkBoolOption "reverse";
        nocombine = mkBoolOption "nocombine";
        link = mkOption {
          type = nullOr str;
          default = null;
          description = "The name of another highlight group to link to";
        };
        default = mkOption {
          type = nullOr bool;
          default = null;
          description = "Don't override existing definition";
        };
        ctermfg = mkOption {
          type = nullOr str;
          default = null;
          description = "The cterm foreground color to use";
        };
        ctermbg = mkOption {
          type = nullOr str;
          default = null;
          description = "The cterm background color to use";
        };
        cterm = mkOption {
          type = nullOr (listOf (enum [
            "bold"
            "underline"
            "undercurl"
            "underdouble"
            "underdotted"
            "underdashed"
            "strikethrough"
            "reverse"
            "inverse"
            "italic"
            "standout"
            "altfont"
            "nocombine"
            "NONE"
          ]));
          default = null;
          description = "The cterm arguments to use. See ':h highlight-args'";
        };
        force = mkBoolOption "force update";
      };
    });
    default = {};
    example = {
      SignColumn = {
        bg = "#282828";
      };
    };
    description = "Custom highlights to apply";
  };

  config = {
    vim.luaConfigRC.highlight = let
      highlights =
        mapAttrsToList (
          name: value: ''vim.api.nvim_set_hl(0, ${toLuaObject name}, ${toLuaObject value})''
        )
        cfg;
    in
      entryBetween ["lazyConfigs" "pluginConfigs" "extraPluginConfigs"] ["theme"] (concatLines highlights);
  };
}
