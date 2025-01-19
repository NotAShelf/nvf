{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption literalExpression;
  inherit (lib.types) nullOr attrsOf listOf submodule bool ints str;
  inherit (lib.strings) hasPrefix concatStringsSep;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) hexColor;

  mkColorOption = target:
    mkOption {
      type = nullOr hexColor;
      default = null;
      description = ''
        The ${target} color to use. Written as color name or hex "#RRGGBB".
      '';
      example = "#ebdbb2";
    };

  mkBoolOption = name:
    mkOption {
      type = nullOr bool;
      default = null;
      description = ''Whether to enable ${name}'';
      example = false;
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
          type = nullOr (listOf str);
          default = null;
          description = "The cterm arguments to use. See :h highlight-args";
        };
        force = mkBoolOption "force update";
      };
    });
    default = {};
    description = "Custom highlight to apply";
    example = literalExpression ''
      {
        SignColumn = {
          bg = "#282828";
        };
      }
    '';
  };

  config = {
    vim.luaConfigRC.highlight = let
      highlights =
        mapAttrsToList (
          name: value: ''vim.api.nvim_set_hl(0, ${toLuaObject name}, ${toLuaObject value})''
        )
        cfg;
    in
      entryAnywhere (concatStringsSep "\n" highlights);
  };
}
