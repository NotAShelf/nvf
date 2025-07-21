{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.assembly;
  defaultServers = ["asm-lsp"];
  servers = {
    asm-lsp = {
      enable = true;
      cmd = [(getExe pkgs.asm-lsp)];
      filetypes = ["asm" "vmasm"];
      root_markers = [".asm-lsp.toml" ".git"];
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
      enable = mkEnableOption "Assembly LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "Assembly" servers defaultServers;
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
