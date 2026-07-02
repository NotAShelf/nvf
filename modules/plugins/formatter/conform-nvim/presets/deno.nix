{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.formatter.conform-nvim.presets.deno;

  extensions = {
    markdown = "md";
    json = "json";
    jsonc = "jsonc";
    yaml = "yml";
    javascript = "js";
    javascriptreact = "jsx";
    typescript = "ts";
    typescriptreact = "tsx";
    css = "css";
    less = "less";
    sass = "sass";
    scss = "scss";
    html = "html";
    # Unstable
    htmlangular = "angular";
    astro = "astro";
    svelte = "svelte";
    vue = "vue";
  };
in {
  options.vim.formatter.conform-nvim.presets.deno = {
    enable = mkFormatterPresetEnableOption {
      option = "deno";
      display = "Deno";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.deno = {
      command = "${pkgs.deno}/bin/deno";
      stdin = true;
      args = mkLuaInline ''
        function(self, ctx)
          local indent = not vim.bo[ctx.buf].expandtab and "--use-tabs=true" or "--use-tabs=false"
          return {
            "fmt", "-",
            "--ext", (${toLuaObject extensions})[vim.bo[ctx.buf].filetype],
            "--indent-width", vim.bo[ctx.buf].shiftwidth,
            indent,
            -- Required to allow using unstable components.
            -- Doesn't crate any problems with stable ones
            "--unstable-component",
          }
        end
      '';
    };
  };
}
