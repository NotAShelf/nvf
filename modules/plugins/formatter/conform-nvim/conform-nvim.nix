{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrs either nullOr;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) luaInline mkPluginSetupOption;
in {
  options.vim.formatter.conform-nvim = {
    enable = mkEnableOption "lightweight yet powerful formatter plugin for Neovim [conform-nvim]";
    setupOpts = mkPluginSetupOption "conform.nvim" {
      formatters_by_ft = mkOption {
        type = attrs;
        default = {};
        example = {lua = ["stylua"];};
        description = ''
          Map of filetype to formatters. This option takes a set of
          `key = value` format where the `value will` be converted
          to its Lua equivalent. You are responsible for passing the
          correct Nix data types to generate a correct Lua value that
          conform is able to accept.
        '';
      };

      default_format_opts = mkOption {
        type = attrs;
        default = {lsp_format = "fallback";};
        description = "Default values when calling `conform.format()`";
      };

      format_on_save = let
        defaultFormatOnSaveOpts = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
      in
        mkOption {
          type = nullOr (either attrs luaInline);
          default =
            mkLuaInline
            # lua
            ''
              function()
                if (not vim.g.formatsave) or (vim.b.disableFormatSave) then
                  return
                else
                  return ${toLuaObject defaultFormatOnSaveOpts}
                end
              end
            '';
          description = ''
            Table or function(lualinline) that will be passed to `conform.format()`. If this
            is set, Conform will run the formatter on save.

            Note:
              - When config.vim.lsp.formatOnSave is set to true, internally
                vim.g.formatsave is set to true.
              - vim.b.disableFormatSave initally equals !config.vim.lsp.formatOnSave.
              - vim.b.disableFormatSave is toggled using the
                mapping from config.vim.lsp.mappings.toggleFormatOnSave.
          '';
        };

      format_after_save = let
        defaultFormatAfterSaveOpts = {lsp_format = "fallback";};
      in
        mkOption {
          type = nullOr (either attrs luaInline);
          default =
            mkLuaInline
            # lua
            ''
              function()
                if (not vim.g.formatsave) or (vim.b.disableFormatSave) then
                  return
                else
                  return ${toLuaObject defaultFormatAfterSaveOpts}
                end
              end
            '';
          description = ''
            Table or function(luainline) that will be passed to `conform.format()`. If this
            is set, Conform will run the formatter asynchronously after save.

            Note:
              - When config.vim.lsp.formatOnSave is set to true, internally
                vim.g.formatsave is set to true.
              - vim.b.disableFormatSave initally equals !config.vim.lsp.formatOnSave.
              - vim.b.disableFormatSave is toggled using the
                mapping from config.vim.lsp.mappings.toggleFormatOnSave.
          '';
        };
    };
  };
}
