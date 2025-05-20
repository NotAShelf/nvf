{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) concatStringsSep;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum package;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.languages) resolveLspOptions mkLspOption;

  cfg = config.vim.languages.nix;

  packageToCmd = package: defaultCmd:
    if isList package
    then expToLua package
    else ''{"${package}/bin/${defaultCmd}"}'';

  formattingCmd = lib.mkIf (cfg.format.enable && cfg.lsp.enable) {
    formatting = lib.mkMerge [
      (lib.mkIf (cfg.format.type == "alejandra") {
        command = ["${cfg.format.package}/bin/alejandra" "--quiet"];
      })
      (lib.mkIf (cfg.format.type == "nixfmt") {
        command = ["${cfg.format.package}/bin/nixfmt"];
      })
    ];
  };

  defaultServers = ["nil_ls"]
  servers = {
    nil_ls = {
      enable = true;
      cmd = ["${pkgs.nil}/bin/nil"];
      settings = {
        nil = formattingCmd;
      };
    };

    nixd = {
      enable = true;
      cmd = ["${pkgs.nixd}/bin/nixd"];
      settings = {
        nixd = formattingCmd;
      };
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
      servers = mkLspOption {
        inherit servers;
        default = defaultServers;
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
      # TODO: Map this to include lspconfig stuff so that we can do
      vim.lsp.servers = resolveLspOptions {
        inherit servers;
        selected = cfg.lsp.servers;
      };
    })

    # TODO: Figure out what do here. This is not necessarily correct as other lsps might not have formatting by default
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
