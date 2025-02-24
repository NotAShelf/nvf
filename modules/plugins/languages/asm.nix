{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.assembly;

  defaultServer = "asm-lsp";
  servers = {
    asm-lsp = {
      package = pkgs.asm-lsp;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "attach_keymaps";
        filetypes = ["asm" "vasm"];
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${getExe cfg.lsp.package}"];
      };
    };
  };
in {
  options.vim.languages.assembly = {
    enable = mkEnableOption "Assembly support";

    treesitter = {
      enable = mkEnableOption "Assembly treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "asm";
    };

    lsp = {
      enable = mkEnableOption "Assembly LSP support (asm-lsp)" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Assembly LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "asm-lsp LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.asm-lsp "--quiet"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };

      options = mkOption {
        type = lspOptions;
        default = servers.${cfg.lsp.server}.options;
        description = ''
          LSP options for Assembly language support.

          This option is freeform, you may add options that are not set by default
          and they will be merged into the final table passed to lspconfig.
        '';
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig = {
        enable = true;
        sources.asm-lsp = ''
          lspconfig.("asm_lsp").setup (${toLuaObject cfg.lsp.options})
        '';
      };
    })
  ]);
}
