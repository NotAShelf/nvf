{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.haskell-language-server;
in {
  options.vim.lsp.presets.haskell-language-server = {
    enable = mkLspPresetEnableOption {
      option = "haskell-language-server";
      display = "Haskell";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.haskell-language-server = {
      enable = true;
      cmd = [
        "${(pkgs.symlinkJoin {
          name = "haskell-language-server-wrapper";
          paths = [pkgs.haskellPackages.haskell-language-server];
          meta.mainProgram = "haskell-language-server-wrapper";
          buildInputs = [pkgs.makeBinaryWrapper];
          # wrap HLS-wrapper so it can find the actual binary
          postBuild = ''
            wrapProgram $out/bin/haskell-language-server-wrapper \
              --prefix PATH : ${pkgs.haskellPackages.haskell-language-server}/bin
          '';
        })}/bin/haskell-language-server-wrapper"
        "--lsp"
      ];
      root_markers = ["hie.yaml" "stack.yaml" "cabal.project" "*.cabal" "package.yaml"];
    };
  };
}
