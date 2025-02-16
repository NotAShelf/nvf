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

  cfg = config.vim.languages.cue;

  defaultServer = "cue";
  servers = {
    cue = {
      package = pkgs.cue;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["cue"];
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${getExe cfg.lsp.package}"];
        single_file_support = true;
      };
    };
  };
in {
  options.vim.languages.cue = {
    enable = mkEnableOption "CUE language support";

    treesitter = {
      enable = mkEnableOption "CUE treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkGrammarOption pkgs "cue";
    };

    lsp = {
      enable = mkEnableOption "CUE LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "CUE LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        description = ''
          CUE LSP server package, or the command to run as a list of strings
        '';
      };

      options = mkOption {
        type = lspOptions;
        default = servers.${cfg.lsp.server}.options;
        description = ''
          LSP options for CUE language support.

          This option is freeform, you may add options that are not set by default
          and they will be merged into the final table passed to lspconfig.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig = {
        enable = true;
        sources.cue-lsp = ''
          lspconfig.${toLuaObject cfg.lsp.server}.setup(${toLuaObject cfg.lsp.options})
        '';
      };
    })
  ]);
}
