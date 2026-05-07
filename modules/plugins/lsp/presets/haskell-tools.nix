{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.haskell-tools;
  haskell-toolsPackage = pkgs.haskellPackages.haskell-language-server;
in {
  options.vim.lsp.presets.haskell-tools = {
    enable = mkLspPresetEnableOption "haskell-tools-nvim" "Haskell" ["haskell"];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.haskell-tools = {
      # The plugin will handle startup
      enable = false;
      # TODO: does this actually work?
      cmd = [(getExe' haskell-toolsPackage "haskell-language-server-wrapper")];
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
  };
}
