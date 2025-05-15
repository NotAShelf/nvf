{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) isList;
  inherit (lib.types) either package listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) expToLua;
  inherit (pkgs) haskellPackages;

  cfg = config.vim.languages.haskell;
in {
  options.vim.languages.haskell = {
    enable = mkEnableOption "Haskell support";

    treesitter = {
      enable = mkEnableOption "Treesitter support for Haskell" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "haskell";
    };

    lsp = {
      enable = mkEnableOption "LSP support for Haskell" // {default = config.vim.lsp.enable;};
      package = mkOption {
        description = "Haskell LSP package or command to run the Haskell LSP";
        example = ''[ (lib.getExe pkgs.haskellPackages.haskell-language-server) "--debug" ]'';
        default = haskellPackages.haskell-language-server;
        type = either package (listOf str);
      };
    };

    dap = {
      enable = mkEnableOption "DAP support for Haskell" // {default = config.vim.languages.enableDAP;};
      package = mkOption {
        description = "Haskell DAP package or command to run the Haskell DAP";
        default = haskellPackages.haskell-debug-adapter;
        type = either package (listOf str);
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf (cfg.dap.enable || cfg.lsp.enable) {
      vim = {
        startPlugins = ["haskell-tools-nvim"];
        luaConfigRC.haskell-tools-nvim =
          entryAfter
          ["lsp-setup"]
          ''
            vim.g.haskell_tools = {
            ${optionalString cfg.lsp.enable ''
              -- LSP
              tools = {
                hover = {
                  enable = true,
                },
              },
              hls = {
                cmd = ${
                if isList cfg.lsp.package
                then expToLua cfg.lsp.package
                else ''{"${cfg.lsp.package}/bin/haskell-language-server-wrapper", "--lsp"}''
              },
                on_attach = function(client, bufnr, ht)
                  default_on_attach(client, bufnr, ht)
                  local opts = { noremap = true, silent = true, buffer = bufnr }
                  vim.keymap.set('n', '<localleader>cl', vim.lsp.codelens.run, opts)
                  vim.keymap.set('n', '<localleader>hs', ht.hoogle.hoogle_signature, opts)
                  vim.keymap.set('n', '<localleader>ea', ht.lsp.buf_eval_all, opts)
                  vim.keymap.set('n', '<localleader>rr', ht.repl.toggle, opts)
                  vim.keymap.set('n', '<localleader>rf', function()
                    ht.repl.toggle(vim.api.nvim_buf_get_name(0))
                  end, opts)
                  vim.keymap.set('n', '<localleader>rq', ht.repl.quit, opts)
                end,
              },
            ''}
            ${optionalString cfg.dap.enable ''
              dap = {
                cmd = ${
                if isList cfg.dap.package
                then expToLua cfg.dap.package
                else ''{"${cfg.dap.package}/bin/haskell-debug-adapter"}''
              },
              },
            ''}
            }
          '';
      };
    })
  ]);
}
