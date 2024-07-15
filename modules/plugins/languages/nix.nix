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
  inherit (lib.strings) optionalString;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.languages) diagnosticsToLua;

  cfg = config.vim.languages.nix;

  useFormat = "on_attach = default_on_attach";
  noFormat = "on_attach = attach_keymaps";

  defaultServer = "nil";
  packageToCmd = package: defaultCmd:
    if isList package
    then expToLua package
    else ''{"${package}/bin/${defaultCmd}"}'';
  servers = {
    rnix = {
      package = pkgs.rnix-lsp;
      internalFormatter = cfg.format.type == "nixpkgs-fmt";
      lspConfig = ''
        lspconfig.rnix.setup{
          capabilities = capabilities,
        ${
          if (cfg.format.enable && cfg.format.type == "nixpkgs-fmt")
          then useFormat
          else noFormat
        },
          cmd = ${packageToCmd cfg.lsp.package "rnix-lsp"},
        }
      '';
    };

    nil = {
      package = pkgs.nil;
      internalFormatter = true;
      lspConfig = ''
        lspconfig.nil_ls.setup{
          capabilities = capabilities,
        ${
          if cfg.format.enable
          then useFormat
          else noFormat
        },
          cmd = ${packageToCmd cfg.lsp.package "nil"},
        ${optionalString cfg.format.enable ''
          settings = {
            ["nil"] = {
          ${optionalString (cfg.format.type == "alejandra")
            ''
              formatting = {
                command = {"${cfg.format.package}/bin/alejandra", "--quiet"},
              },
            ''}
          ${optionalString (cfg.format.type == "nixpkgs-fmt")
            ''
              formatting = {
                command = {"${cfg.format.package}/bin/nixpkgs-fmt"},
              },
            ''}
            },
          },
        ''}
        }
      '';
    };
  };

  defaultFormat = "alejandra";
  formats = {
    alejandra = {
      package = pkgs.alejandra;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.alejandra.with({
            command = "${cfg.format.package}/bin/alejandra"
          })
        )
      '';
    };

    nixpkgs-fmt = {
      package = pkgs.nixpkgs-fmt;
      # Never need to use null-ls for nixpkgs-fmt
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
      enable = mkEnableOption "Nix LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        description = "Nix LSP server to use";
        type = str;
        default = defaultServer;
      };

      package = mkOption {
        description = "Nix LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
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
      vim.pluginRC.nix = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "nix",
          callback = function(opts)
            bo = vim.bo[opts.buf]
            bo.tabstop = 2
            bo.shiftwidth = 2
            bo.softtabstop = 2
          end
        })
      '';
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.nix-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf (cfg.format.enable && !servers.${cfg.lsp.server}.internalFormatter) {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.nix-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = diagnosticsToLua {
        lang = "nix";
        config = cfg.extraDiagnostics.types;
        inherit diagnosticsProviders;
      };
    })
  ]);
}
