{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets;
in {
  options.vim.formatter.conform-nvim.presets = {
    ruff = {
      enable = mkFormatterPresetEnableOption {
        option = "ruff";
        display = "Ruff";
      };
    };
    ruff-fix = {
      enable = mkFormatterPresetEnableOption {
        option = "ruff-fix";
        display = "Ruff";
        extra = "This variant runs automatic linter fixes.";
      };
    };
    ruff-organize-imports = {
      enable = mkFormatterPresetEnableOption {
        option = "ruff-organize-imports";
        display = "Ruff";
        extra = "This variant organizes imports.";
      };
    };
  };

  config = {
    vim.formatter.conform-nvim.setupOpts.formatters = {
      ruff = mkIf cfg.ruff.enable {
        command = "${pkgs.ruff}/bin/ruff";
        stdin = true;
        args = mkLuaInline ''
          function(self, ctx)
            local style = vim.bo[ctx.buf].expandtab and "'space'" or "'tab'"

            return {
              "format",
              "--config", "format.indent-width = " .. vim.bo[ctx.buf].shiftwidth,
              "--config", "format.indent-style = " .. style,
              "--force-exclude",
              "--stdin-filename", "$FILENAME",
              "-"
            }
          end
        '';
        range_args = mkLuaInline ''
          function(self, ctx)
            local style = vim.bo[ctx.buf].expandtab and "'space'" or "'tab'"

            return {
              "format",
              "--config", "format.indent-width = " .. vim.bo[ctx.buf].shiftwidth,
              "--config", "format.indent-style = " .. style,
              "--force-exclude",
              "--range", string.format(
                "%d:%d-%d:%d",
                ctx.range.start[1],
                ctx.range.start[2] + 1,
                ctx.range["end"][1],
                ctx.range["end"][2] + 1
              ),
              "--stdin-filename", "$FILENAME",
              "-",
            }
          end
        '';
      };
      ruff-fix = mkIf cfg.ruff-fix.enable {
        command = "${pkgs.ruff}/bin/ruff";
        stdin = true;
        args = [
          "check"
          "--fix"
          "--force-exclude"
          "--exit-zero"
          "--no-cache"
          "--stdin-filename"
          "$FILENAME"
          "-"
        ];
      };
      ruff-organize-imports = mkIf cfg.ruff-organize-imports.enable {
        command = "${pkgs.ruff}/bin/ruff";
        stdin = true;
        args = [
          "check"
          "--fix"
          "--force-exclude"
          "--select=I001"
          "--exit-zero"
          "--no-cache"
          "--stdin-filename"
          "$FILENAME"
          "-"
        ];
      };
    };
  };
}
