{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) bool enum package;
  inherit (lib.lists) optional;
  inherit (lib.nvim.types) mkGrammarOption diagnostics singleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.html;

  defaultServers = ["superhtml"];
  servers = {
    superhtml = {
      cmd = [(getExe pkgs.superhtml) "lsp"];
      filetypes = ["html" "shtml" "htm"];
      root_markers = ["index.html" ".git"];
    };
  };

  defaultFormat = "superhtml";
  formats = {
    superhtml = {
      package = pkgs.writeShellApplication {
        name = "superhtml_fmt";
        runtimeInputs = [pkgs.superhtml];
        text = "superhtml fmt -";
      };
    };
  };
  
  defaultDiagnosticsProvider = ["htmlhint"];
  diagnosticsProviders = {
    htmlhint = {
      package = pkgs.htmlhint;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.htmlhint.with({
            command = "${pkg}/bin/htmlhint"
          })
        )
      '';
    };
  };

in {
  options.vim.languages.html = {
    enable = mkEnableOption "HTML language support";
    treesitter = {
      enable = mkEnableOption "HTML treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "html";
      autotagHtml = mkOption {
        description = "Enable autoclose/autorename of html tags (nvim-ts-autotag)";
        type = bool;
        default = true;
      };
    };

    lsp = {
      enable = mkEnableOption "HTML LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "HTML LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "HTML formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "HTML formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "HTML formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra HTML diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      
      types = diagnostics {
        langDesc = "HTML";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };
    
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim = {
        startPlugins = optional cfg.treesitter.autotagHtml "nvim-ts-autotag";

        treesitter = {
          enable = true;
          grammars = [cfg.treesitter.package];
        };

        pluginRC.html-autotag = mkIf cfg.treesitter.autotagHtml (entryAnywhere ''
          require('nvim-ts-autotag').setup()
        '');
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers = 
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.html = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.html = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
          ${name}.cmd = getExe diagnosticsProviders.${name}.package;
        })
        cfg.extraDiagnostics.types);
      };
    })
  ]);
}
