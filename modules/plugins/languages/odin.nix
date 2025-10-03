{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  defaultServers = ["ols"];
  servers = {
    ols = {
      enable = true;
      cmd = [(getExe pkgs.ols)];
      filetypes = ["odin"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('ols.json', '.git', '*.odin')(fname))
          end'';
    };
  };

  cfg = config.vim.languages.odin;
in {
  options.vim.languages.odin = {
    enable = mkEnableOption "Odin language support";

    treesitter = {
      enable = mkEnableOption "Odin treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "odin";
    };

    lsp = {
      enable = mkEnableOption "Odin LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Odin LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
