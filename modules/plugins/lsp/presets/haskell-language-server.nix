{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.haskell-language-server;
  cabalFmtCfg = config.vim.languages.haskell.cabalFormat;
  cabalFormats = {
    cabal-fmt = pkgs.haskellPackages.cabal-fmt;
    cabal-gild = pkgs.haskellPackages.cabal-gild;
  };
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
      settings = mkIf cabalFmtCfg.enable {
        haskell = {
          cabalFormattingProvider = cabalFmtCfg.type;
          # This option is undocumented in the haskell-language-server docs, but it does exist in the plugin API
          # https://github.com/haskell/haskell-language-server/blob/f158128ec034bec1667c440262641086bbb4d359/plugins/hls-cabal-fmt-plugin/src/Ide/Plugin/CabalFmt.hs#L51
          plugin.${cabalFmtCfg.type}.config.path = getExe cabalFormats.${cabalFmtCfg.type};
        };
      };
    };
  };
}
