{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.haskell-language-server;
in {
  options.vim.lsp.presets.haskell-language-server = {
    enable = mkLspPresetEnableOption "haskell-language-server" "Haskell" [];
  };

  config = mkIf cfg.enable {
    vim.extraPackages = [pkgs.haskellPackages.cabal-fmt];
    vim.lsp.servers.haskell-language-server = {
      enable = true;
      cmd = [(getExe' pkgs.haskellPackages.haskell-language-server "haskell-language-server-wrapper") "--lsp"];
      root_markers = ["hie.yaml" "stack.yaml" "cabal.project" "*.cabal" "package.yaml"];
      settings = {
        haskell = {
          formattingProvider = "ormolu";
          cabalFormattingProvider = "cabal-fmt";
        };
      };
    };
  };
}
