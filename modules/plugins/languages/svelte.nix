{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum package coercedTo;
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.svelte;

  defaultServers = ["svelte"];
  servers = {
    svelte = {
      enable = true;
      cmd = [(getExe pkgs.svelte-language-server) "--stdio"];
      filetypes = ["svelte"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local root_files = { 'package.json', '.git' }
          local fname = vim.api.nvim_buf_get_name(bufnr)
          -- Svelte LSP only supports file:// schema. https://github.com/sveltejs/language-tools/issues/2777
          if vim.uv.fs_stat(fname) ~= nil then
            on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
          end
        end
      '';
      on_attach = mkLuaInline ''
        function(client, bufnr)
          vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.js', '*.ts' },
            group = vim.api.nvim_create_augroup('svelte_js_ts_file_watch', {}),
            callback = function(ctx)
              -- internal API to sync changes that have not yet been saved to the file system
              client:notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
            end,
          })

          vim.api.nvim_buf_create_user_command(bufnr, 'LspMigrateToSvelte5', function()
            client:exec_cmd({
              command = 'migrate_to_svelte_5',
              arguments = { vim.uri_from_bufnr(bufnr) },
            })
          end, { desc = 'Migrate Component to Svelte 5 Syntax' })
        end
      '';
    };
  };

  defaultFormat = ["prettier"];
  formats = let
    prettierPlugin = self.packages.${pkgs.stdenv.system}.prettier-plugin-svelte;
    prettierPluginPath = "${prettierPlugin}/lib/node_modules/prettier-plugin-svelte/plugin.js";
  in {
    prettier = {
      command = getExe pkgs.nodePackages.prettier;
      options.ft_parsers.svelte = "svelte";
      prepend_args = ["--plugin=${prettierPluginPath}"];
    };

    biome = {
      command = getExe pkgs.biome;
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = let
      pkg = pkgs.eslint_d;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
        required_files = [
          "eslint.config.js"
          "eslint.config.mjs"
          ".eslintrc"
          ".eslintrc.json"
          ".eslintrc.js"
          ".eslintrc.yml"
        ];
      };
    };
  };

  formatType =
    deprecatedSingleOrListOf
    "vim.languages.svelte.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.svelte.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum (attrNames formats)));
in {
  options.vim.languages.svelte = {
    enable = mkEnableOption "Svelte language support";

    treesitter = {
      enable = mkEnableOption "Svelte treesitter" // {default = config.vim.languages.enableTreesitter;};

      sveltePackage = mkGrammarOption pkgs "svelte";
    };

    lsp = {
      enable = mkEnableOption "Svelte LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.svelte.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Svelte LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Svelte formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = formatType;
        default = defaultFormat;
        description = "Svelte formatter to use";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Svelte diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Svelte";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.sveltePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.svelte = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.svelte = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
