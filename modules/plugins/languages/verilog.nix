{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.verilog;
in {
  options.vim.languages.verilog = {
    enable = mkEnableOption "Verilog support";

    treesitter = {
      enable =
        mkEnableOption "Verilog treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
        };
      package = mkGrammarOption pkgs "systemverilog";
    };

    lsp = {
      enable =
        mkEnableOption "Verilog LSP support (verible)"
        // {
          default = config.vim.lsp.enable;
        };

      package = mkOption {
        type = package;
        default = pkgs.verible;
        description = "verible package";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.verible = ''
        lspconfig.verible.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"${cfg.lsp.package}/bin/verible-verilog-ls", "-sv", "-Wall"},
        }
      '';
    })
  ]);
}
