{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;

  cfg = config.vim.languages.cue;

  defaultServers = ["cue"];
  servers = {
    cue = {
      enable = true;
      cmd = [(getExe pkgs.cue) "lsp"];
      filetypes = ["cue"];
      root_markers = ["cue.mod" ".git"];
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
      enable = mkEnableOption "CUE LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "CUE" servers defaultServers;
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
