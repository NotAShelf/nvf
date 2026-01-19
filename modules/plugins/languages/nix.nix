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
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.nix;

  defaultServers = ["nil"];
  servers = {
    nil = {
      enable = true;
      cmd = [(getExe pkgs.nil)];
      filetypes = ["nix"];
      root_markers = [".git" "flake.nix"];
    };

    nixd = {
      enable = true;
      cmd = [(getExe pkgs.nixd)];
      filetypes = ["nix"];
      root_markers = [".git" "flake.nix"];
    };
  };

  defaultFormat = ["alejandra"];
  formats = {
    alejandra = {
      command = getExe pkgs.alejandra;
    };

    nixfmt = {
      command = getExe pkgs.nixfmt;
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
        type = deprecatedSingleOrListOf "vim.language.nix.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Nix LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Nix formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Nix formatter to use";
        type = deprecatedSingleOrListOf "vim.language.nix.format.type" (enum (attrNames formats));
        default = defaultFormat;
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

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.nix = cfg.format.type;
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
        linters_by_ft.nix = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
