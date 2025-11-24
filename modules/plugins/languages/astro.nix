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
  inherit (lib.types) enum coercedTo;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.astro;

  defaultServers = ["astro"];
  servers = {
    astro = {
      enable = true;
      cmd = [(getExe pkgs.astro-language-server) "--stdio"];
      filetypes = ["astro"];
      root_markers = ["package.json" "tsconfig.json" "jsconfig.json" ".git"];
      init_options = {
        typescript = {};
      };
      before_init =
        mkLuaInline
        /*
        lua
        */
        ''
          function(_, config)
            if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
              config.init_options.typescript.tsdk = util.get_typescript_server_path(config.root_dir)
            end
          end
        '';
    };
  };

  defaultFormat = ["prettier"];
  formats = let
    parser = "${self.packages.${pkgs.stdenv.system}.prettier-plugin-astro}/index.js";
  in {
    prettier = {
      command = getExe pkgs.nodePackages.prettier;
      options.ft_parsers.astro = "astro";
      prepend_args = ["--plugin=${parser}"];
    };

    biome = {
      command = getExe pkgs.biome;
    };
  };

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
    "vim.languages.astro.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.astro.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum (attrNames formats)));
in {
  options.vim.languages.astro = {
    enable = mkEnableOption "Astro language support";

    treesitter = {
      enable = mkEnableOption "Astro treesitter" // {default = config.vim.languages.enableTreesitter;};

      astroPackage = mkGrammarOption pkgs "astro";
    };

    lsp = {
      enable = mkEnableOption "Astro LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.astro.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Astro LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Astro formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = formatType;
        default = defaultFormat;
        description = "Astro formatter to use";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Astro diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Astro";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.astroPackage];
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
          formatters_by_ft.astro = cfg.format.type;
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
        linters_by_ft.astro = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
