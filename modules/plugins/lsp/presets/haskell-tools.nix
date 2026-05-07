{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.trivial) warn;

  cfg = config.vim.lsp.presets.haskell-tools;
  lspCfg = config.vim.lsp.servers.haskell-tools;
in {
  options.vim.lsp.presets.haskell-tools = {
    enable = mkLspPresetEnableOption "haskell-tools-nvim" "Haskell" ["haskell"];
  };

  config = mkIf cfg.enable {
    vim = {
      lsp.servers.haskell-tools = {
        # The plugin will handle startup
        enable = false;
        # NOTE: pkgs.haskell-language-server does not expose the haskell-language-server program
        on_attach = mkLuaInline ''
          function(client, bufnr)
              local ht = require("haskell-tools")
              local opts = { noremap = true, silent = true, buffer = bufnr }
              vim.keymap.set('n', '<localleader>cl', vim.lsp.codelens.run, opts)
              vim.keymap.set('n', '<localleader>hs', ht.hoogle.hoogle_signature, opts)
              vim.keymap.set('n', '<localleader>ea', ht.lsp.buf_eval_all, opts)
              vim.keymap.set('n', '<localleader>rr', ht.repl.toggle, opts)
              vim.keymap.set('n', '<localleader>rf', function()
                ht.repl.toggle(vim.api.nvim_buf_get_name(0))
              end, opts)
              vim.keymap.set('n', '<localleader>rq', ht.repl.quit, opts)
            end
        '';
        settings = {
          haskell = {
            formattingProvider = "ormolu";
            cabalFormattingProvider = "cabal-fmt";
          };
        };
      };

      languages.haskell.extensions.haskell-tools-nvim = {
        enable = true;
        setupOpts = {
          hls = {
            cmd =
              if (lspCfg.cmd != null)
              then
                warn ''
                  config.vim.lsp.servers.haskell-tools.cmd: this option is
                  ignored by haskell-tools, use
                  vim.languages.haskell.extensions.haskell-tools-nvim.setupOpts.hls.cmd
                  instead.
                ''
                lspCfg.cmd
              else [
                "${pkgs.haskellPackages.haskell-language-server}/bin/haskell-language-server"
                "--lsp"
              ];
          };
        };
      };
    };
  };
}
