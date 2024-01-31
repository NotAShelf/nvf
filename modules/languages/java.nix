{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) isList nvim mkEnableOption mkOption types mkIf mkMerge getExe;

  cfg = config.vim.languages.java;
in {
  options.vim.languages.java = {
    enable = mkEnableOption "Java language support";

    treesitter = {
      enable = mkEnableOption "Java treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = nvim.types.mkGrammarOption pkgs "java";
    };

    lsp = {
      enable = mkEnableOption "Java LSP support (java-language-server)" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "java language server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = with types; either package (listOf str);
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
          then nvim.lua.expToLua cfg.lsp.package
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
