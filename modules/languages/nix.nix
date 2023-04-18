{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.nix;

  useFormat = "on_attach = default_on_attach";
  noFormat = "on_attach = attach_keymaps";

  defaultServer = "nil";
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
          cmd = {"${cfg.lsp.package}/bin/rnix-lsp"},
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
          cmd = {"${cfg.lsp.package}/bin/nil"},
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
        ''}
            },
          };
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
in {
  options.vim.languages.nix = {
    enable = mkEnableOption "Nix language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Nix treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "nix";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Nix LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Nix LSP server to use";
        type = types.str;
        default = defaultServer;
      };
      package = mkOption {
        description = "Nix LSP server package";
        type = types.package;
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Nix formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Nix formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = mkOption {
        description = "Nix formatter package";
        type = types.package;
        default = formats.${cfg.format.type}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.configRC.nix = nvim.dag.entryAnywhere ''
        autocmd filetype nix setlocal tabstop=2 shiftwidth=2 softtabstop=2
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
  ]);
}
