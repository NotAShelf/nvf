{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption diagnostics singleOrListOf;
  inherit (lib.types) package enum;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.ruby;

  defaultServers = ["solargraph"];
  servers = {
    ruby_lsp = {
      enable = true;
      cmd = [(getExe pkgs.ruby-lsp)];
      filetypes = ["ruby" "eruby"];
      root_markers = ["Gemfile" ".git"];
      init_options = {
        formatter = "auto";
      };
    };

    solargraph = {
      enable = true;
      cmd = [(getExe pkgs.rubyPackages.solargraph) "stdio"];
      filetypes = ["ruby"];
      root_markers = ["Gemfile" ".git"];
      settings = {
        solargraph = {
          diagnostics = true;
        };
      };

      flags = {
        debounce_text_changes = 150;
      };

      init_options = {
        formatting = true;
      };
    };
  };

  # testing

  defaultFormat = "rubocop";
  formats = {
    rubocop = {
      # TODO: is this right?
      package = pkgs.rubyPackages.rubocop;
    };
  };

  defaultDiagnosticsProvider = ["rubocop"];
  diagnosticsProviders = {
    rubocop = {
      package = pkgs.rubyPackages.rubocop;
      config.command = getExe cfg.format.package;
    };
  };
in {
  options.vim.languages.ruby = {
    enable = mkEnableOption "Ruby language support";

    treesitter = {
      enable = mkEnableOption "Ruby treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "ruby";
    };

    lsp = {
      enable = mkEnableOption "Ruby LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Ruby LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Ruby formatter support" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Ruby formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Ruby formatter package";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "Ruby extra diagnostics support"
        // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Ruby";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
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
        setupOpts.formatters_by_ft.ruby = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.ruby = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
