{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.types) diagnostics mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.verilog;
  defaultServer = "verible";
  servers = {
    svls = {
      package = pkgs.svls;
      lspConfig = ''
        lspconfig.verible.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}"}''
        },
        }
      '';
    };
    verible = {
      package = pkgs.verible;
      lspConfig = ''
        lspconfig.verible.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/verible-verilog-ls", "--rules_config_search"}''
        },
        }
      '';
    };
  };
  defaultDiagnosticsProvider = [ "verilator" ];
  diagnosticsProviders = {
    svlint = {
      package = pkgs.svlint;
    };
    verible = {
      package = pkgs.verible;

    };
    verilator = {
      package = pkgs.verilator;
    };
  };
in {
  options.vim.languages.verilog = {
    enable = mkEnableOption "SystemVerilog language support";

    treesitter = {
      enable = mkEnableOption "SystemVerilog treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "verilog";
    };

    lsp = {
      enable = mkEnableOption "SystemVerilog LSP support" // {default = config.vim.lsp.enable;};

      package = mkOption {
        description = "SystemVerilog LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };

      server = mkOption {
        description = "SystemVerilog LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra SystemVerilog diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "SystemVerilog";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.verilog-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.verilog = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
