{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) singleOrListOf;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.tailwind;

  defaultServers = ["tailwindcss"];
  servers = {
    tailwindcss = {
      enable = true;
      cmd = [(getExe pkgs.tailwindcss-language-server) "--stdio"];
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
        "mdx"
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
    };
  };
in {
  options.vim.languages.tailwind = {
    enable = mkEnableOption "Tailwindcss language support";

    lsp = {
      enable = mkEnableOption "Tailwindcss LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Tailwindcss LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
