{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package bool;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) diagnostics mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.bash;

  defaultServers = ["bash-ls"];
  servers = {
    bash-ls = {
      enable = true;
      cmd = [(getExe pkgs.bash-language-server) "start"];
      filetypes = ["bash" "sh"];
      root_markers = [".git"];
      settings = {
        basheIde = {
          globPattern = mkLuaInline "vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)'";
        };
      };
    };
  };

  defaultFormat = "shfmt";
  formats = {
    shfmt = {
      package = pkgs.shfmt;
    };
  };

  defaultDiagnosticsProvider = ["shellcheck"];
  diagnosticsProviders = {
    shellcheck = {
      package = pkgs.shellcheck;
    };
  };
in {
  options.vim.languages.bash = {
    enable = mkEnableOption "Bash language support";

    treesitter = {
      enable = mkEnableOption "Bash treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "bash";
    };

    lsp = {
      enable = mkEnableOption "Bash LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Bash LSP server to use";
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable Bash formatting";
      };
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Bash formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Bash formatter package";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Bash diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "Bash";
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
        setupOpts.formatters_by_ft.sh = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.sh = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
