{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.tailwindcss-language-server;

  filetypes = [
    # html
    "aspnetcorerazor"
    "astro"
    "astro-markdown"
    "blade"
    "clojure"
    "django-html"
    "htmldjango"
    "edge"
    "eelixir"
    "elixir"
    "ejs"
    "erb"
    "eruby"
    "gohtml"
    "gohtmltmpl"
    "haml"
    "handlebars"
    "hbs"
    "html"
    "htmlangular"
    "html-eex"
    "heex"
    "jade"
    "leaf"
    "liquid"
    "markdown"
    "mustache"
    "njk"
    "nunjucks"
    "php"
    "razor"
    "slim"
    "twig"
    # css
    "css"
    "less"
    "postcss"
    "sass"
    "scss"
    "stylus"
    "sugarss"
    # js
    "javascript"
    "javascriptreact"
    "reason"
    "rescript"
    "typescript"
    "typescriptreact"
    # mixed
    "vue"
    "svelte"
    "templ"
  ];
in {
  options.vim.lsp.presets.tailwindcss-language-server = {
    enable = mkLspPresetEnableOption {
      option = "tailwindcss-language-server";
      display = "Tailwind CSS";
      fileTypes = filetypes;
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.tailwindcss-language-server = {
      enable = true;
      cmd = [(getExe pkgs.tailwindcss-language-server) "--stdio"];
      root_markers = [".git"];
      inherit filetypes;
      settings = {
        tailwindCSS = {
          validate = true;
          lint = {
            cssConflict = "warning";
            invalidApply = "error";
            invalidScreen = "error";
            invalidVariant = "error";
            invalidConfigPath = "error";
            invalidTailwindDirective = "error";
            recommendedVariantOrder = "warning";
          };
          classAttributes = [
            "class"
            "className"
            "class:list"
            "classList"
            "ngClass"
          ];
          includeLanguages = {
            eelixir = "html-eex";
            elixir = "phoenix-heex";
            eruby = "erb";
            heex = "phoenix-heex";
            htmlangular = "html";
            templ = "html";
          };
        };
      };
      workspace_required = true;
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local root_files = {
            -- Generic
            'tailwind.config.js',
            'tailwind.config.cjs',
            'tailwind.config.mjs',
            'tailwind.config.ts',
            'postcss.config.js',
            'postcss.config.cjs',
            'postcss.config.mjs',
            'postcss.config.ts',
            -- Django
            'theme/static_src/tailwind.config.js',
            'theme/static_src/tailwind.config.cjs',
            'theme/static_src/tailwind.config.mjs',
            'theme/static_src/tailwind.config.ts',
            'theme/static_src/postcss.config.js',
          }
          local fname = vim.api.nvim_buf_get_name(bufnr)
          root_files = util.insert_package_json(root_files, 'tailwindcss', fname)
          root_files = util.root_markers_with_field(root_files, { 'mix.lock', 'Gemfile.lock' }, 'tailwind', fname)
          on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
        end
      '';

      before_init = mkLuaInline ''
        function(_, config)
          if not config.settings then
            config.settings = {}
          end
          if not config.settings.editor then
            config.settings.editor = {}
          end
          if not config.settings.editor.tabSize then
            config.settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
          end
        end
      '';
    };
  };
}
