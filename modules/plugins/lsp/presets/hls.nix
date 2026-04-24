{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.hls;
in {
  options.vim.lsp.presets.hls = {
    enable = mkLspPresetEnableOption "hls" "Haskell" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.hls = {
      enable = true;
      cmd = [(getExe' pkgs.haskellPackages.haskell-language-server "haskell-language-server-wrapper") "--lsp"];
      filetypes = ["haskell" "lhaskell"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('hie.yaml', 'stack.yaml', 'cabal.project', '*.cabal', 'package.yaml')(fname))
          end
        '';
      settings = {
        haskell = {
          formattingProvider = mkDefault "ormolu";
          cabalFormattingProvider = "cabal-fmt";
        };
      };
    };
  };
}
