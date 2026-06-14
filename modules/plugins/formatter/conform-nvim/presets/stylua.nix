{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.stylua;
in {
  options.vim.formatter.conform-nvim.presets.stylua = {
    enable = mkFormatterPresetEnableOption {
      option = "stylua";
      display = "Stylua";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.stylua = {
      command = "${pkgs.stylua}/bin/stylua";
      args = mkLuaInline ''
        function(self, ctx)
          local style = vim.bo[ctx.buf].expandtab and "Spaces" or "Tabs"
          return {
            "--search-parent-directories",
            "--respect-ignores",
            "--stdin-filepath",
            "--indent-width",
            vim.bo[ctx.buf].shiftwidth,
            "--indent-type",
            style,
            "$FILENAME",
            "-"
          }
        end
      '';
      range_args = mkLuaInline ''
        function(self, ctx)
          local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
          local style = vim.bo[ctx.buf].expandtab and "Spaces" or "Tabs"
          return {
            "--search-parent-directories",
            "--stdin-filepath",
            "--indent-width",
            vim.bo[ctx.buf].shiftwidth,
            "--indent-type",
            style,
            "$FILENAME",
            "--range-start",
            tostring(start_offset),
            "--range-end",
            tostring(end_offset),
            "-",
          }
        end,
      '';
    };
  };
}
