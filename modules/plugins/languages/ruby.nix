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
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf;
  inherit (lib.types) enum;
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

  defaultFormat = ["rubocop"];
  formats = {
    rubocop = {
      command = getExe pkgs.rubyPackages.rubocop;
    };
  };

  defaultDiagnosticsProvider = ["rubocop"];
  diagnosticsProviders = {
    rubocop = {
      package = pkgs.rubyPackages.rubocop;
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
        type = deprecatedSingleOrListOf "vim.language.ruby.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Ruby LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Ruby formatter support" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.ruby.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Ruby formatter to use";
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
        setupOpts = {
          formatters_by_ft.ruby = cfg.format.type;
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
        linters_by_ft.ruby = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
