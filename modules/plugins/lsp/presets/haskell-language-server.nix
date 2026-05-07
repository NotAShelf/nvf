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
          postBuild = ''
            wrapProgram $out/bin/haskell-language-server-wrapper \
              --prefix PATH : ${pkgs.haskellPackages.cabal-fmt}/bin
          '';
        }) "haskell-language-server-wrapper")
        "--lsp"
      ];
      root_markers = ["hie.yaml" "stack.yaml" "cabal.project" "*.cabal" "package.yaml"];
      settings = {
        haskell = {
          # formatting is handled by conform-nvim; disable HLS's built-in formatter
          formattingProvider = "none";
          # cabal-fmt is an external tool; it is wrapped into the LSP binary's PATH above
          cabalFormattingProvider = "cabal-fmt";
        };
      };
    };
  };
}
