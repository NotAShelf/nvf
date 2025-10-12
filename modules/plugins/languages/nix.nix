{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) concatStringsSep;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.types) mkGrammarOption diagnostics singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.nix;

  formattingCmd = mkIf (cfg.format.enable && cfg.lsp.enable) {
    formatting = mkMerge [
      (mkIf (cfg.format.type == "alejandra") {
        command = ["${cfg.format.package}/bin/alejandra" "--quiet"];
      })
      (mkIf (cfg.format.type == "nixfmt") {
        command = ["${cfg.format.package}/bin/nixfmt"];
      })
    ];
  };

  defaultServers = ["nil"];
  servers = {
    nil = {
      enable = true;
      cmd = [(getExe pkgs.nil)];
      settings = {
        nil = formattingCmd;
      };
      filetypes = ["nix"];
      root_markers = [".git" "flake.nix"];
    };

    nixd = {
      enable = true;
      cmd = [(getExe pkgs.nixd)];
      settings = {
        nixd = formattingCmd;
      };
      filetypes = ["nix"];
      root_markers = [".git" "flake.nix"];
    };
  };

  defaultFormat = "alejandra";
  formats = {
    alejandra = {
      package = pkgs.alejandra;
    };

    nixfmt = {
      package = pkgs.nixfmt-rfc-style;
    };
  };

  defaultDiagnosticsProvider = ["statix" "deadnix"];
  diagnosticsProviders = {
    statix = {
      package = pkgs.statix;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.statix.with({
            command = "${pkg}/bin/statix",
          })
        )
      '';
    };

    deadnix = {
      package = pkgs.deadnix;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.deadnix.with({
            command = "${pkg}/bin/deadnix",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.nix = {
    enable = mkEnableOption "Nix language support";

    treesitter = {
      enable = mkEnableOption "Nix treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "nix";
    };

    lsp = {
      enable = mkEnableOption "Nix LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Nix LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Nix formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Nix formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Nix formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Nix diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Nix";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.format.type != "nixpkgs-fmt";
          message = ''
            nixpkgs-fmt has been archived upstream. Please use one of the following available formatters:
            ${concatStringsSep ", " (attrNames formats)}
          '';
        }
      ];
    }

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

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.nix = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.nix = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
