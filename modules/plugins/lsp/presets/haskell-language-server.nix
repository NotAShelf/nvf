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
          /*
          Wrap HLS-wrapper so it can find the actual GHC-specific binary.

          HLS binaries are incredibly picky about which GHC version they run against
          -- even failing between two GHC builds with identical version numbers, because one has a newer ABI.

          Because of this, we shouldn't assume our provided HLS version is the right
          one for a given project. Appending to PATH with `--suffix` takes advantage
          of PATH's first-match lookup, so an existing HLS already in
          the user's dev environment is found first and takes precedence over ours.
          This way we provide a useful default without clobbering existing setups.
          */
          postBuild = ''
            wrapProgram $out/bin/haskell-language-server-wrapper \
              --suffix PATH : ${pkgs.haskellPackages.haskell-language-server}/bin
          '';
        })}/bin/haskell-language-server-wrapper"
        "--lsp"
      ];
      root_markers = ["hie.yaml" "stack.yaml" "cabal.project" "*.cabal" "package.yaml"];
    };
  };
}
