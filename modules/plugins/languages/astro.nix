{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;

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

  # TODO: specify packages
  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.prettier;
    };

    prettierd = {
      package = pkgs.prettierd;
    };

    biome = {
      package = pkgs.biome;
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
        description = "Astro LSP server to use";
        type = listOf (enum (attrNames servers));
        default = defaultServers;
      };
    };

    format = {
      enable = mkEnableOption "Astro formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Astro formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Astro formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
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
        setupOpts.formatters_by_ft.astro = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
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
