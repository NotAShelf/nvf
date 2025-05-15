{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.types) either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.java;
in {
  options.vim.languages.java = {
    enable = mkEnableOption "Java language support";

    treesitter = {
      enable = mkEnableOption "Java treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "java";
    };

    lsp = {
      enable = mkEnableOption "Java LSP support (java-language-server)" // {default = config.vim.lsp.enable;};
      package = mkOption {
        description = "java language server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = pkgs.jdt-language-server;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.jdtls = ''
        lspconfig.jdtls.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}", "-data", vim.fn.stdpath("cache").."/jdtls/workspace"}''
        },
        }
      '';
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
