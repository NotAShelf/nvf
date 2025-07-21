{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;
  inherit (lib.options) mkEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.wgsl;

  defaultServers = ["wgsl_analyzer"];
  servers = {
    wgsl_analyzer = {
      enable = true;
      cmd = [(getExe pkgs.wgsl-analyzer)];
      filetypes = ["wgsl"];
      root_markers = [".git"];
      settings = {};
    };
  };
in {
  options.vim.languages.wgsl = {
    enable = mkEnableOption "WGSL language support";

    treesitter = {
      enable = mkEnableOption "WGSL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "wgsl";
    };

    lsp = {
      enable = mkEnableOption "WGSL LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "WGSL" servers defaultServers;
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
