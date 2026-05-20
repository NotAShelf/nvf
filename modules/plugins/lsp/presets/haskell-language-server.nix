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
    vim.lsp.servers.haskell-language-server = {
      enable = true;
      cmd = [
        (getExe' (pkgs.symlinkJoin {
          name = "haskell-language-server-wrapper";
          paths = [pkgs.haskellPackages.haskell-language-server];
          meta.mainProgram = "haskell-language-server-wrapper";
          buildInputs = [pkgs.makeBinaryWrapper];
        }) "haskell-language-server-wrapper")
        "--lsp"
      ];
      root_markers = ["hie.yaml" "stack.yaml" "cabal.project" "*.cabal" "package.yaml"];
    };
  };
}
