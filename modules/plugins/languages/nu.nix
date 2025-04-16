{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str either package listOf enum;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption;

  defaultServer = "nushell";
  servers = {
    nushell = {
      package = pkgs.nushell;
      options = {
        cmd =
          if isList cfg.lsp.package
          then toLuaObject cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}", "--no-config-file", "--lsp"}'';
      };
    };
  };

  cfg = config.vim.languages.nu;
in {
  options.vim.languages.nu = {
    enable = mkEnableOption "Nu language support";

    treesitter = {
      enable = mkEnableOption "Nu treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "nu";
    };

    lsp = {
      enable = mkEnableOption "Nu LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = [defaultServer];
        description = "Nu LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[(lib.getExe pkgs.nushell) "--lsp"]'';
        description = "Nu LSP server package, or the command to run as a list of strings";
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
      vim.lsp.lspconfig.sources.nu-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
