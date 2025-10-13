{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.types) either package enum listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.meta) getExe';
  inherit (lib.generators) mkLuaInline;
  inherit (pkgs) haskellPackages;

  cfg = config.vim.languages.haskell;

  defaultServers = ["hls"];
  servers = {
    hls = {
      enable = false;
      cmd = [(getExe' pkgs.haskellPackages.haskell-language-server "haskell-language-server-wrapper") "--lsp"];
      filetypes = ["haskell" "lhaskell"];
      on_attach =
        mkLuaInline
        /*
        lua
        */
        ''
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
          formattingProvider = "ormolu";
          cabalFormattingProvider = "cabalfmt";
        };
      };
    };
  };
in {
  options.vim.languages.haskell = {
    enable = mkEnableOption "Haskell support";

    treesitter = {
      enable = mkEnableOption "Treesitter support for Haskell" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "haskell";
    };

    lsp = {
      enable = mkEnableOption "Haskell LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Haskell LSP server to use";
      };
    };

    dap = {
      enable = mkEnableOption "DAP support for Haskell" // {default = config.vim.languages.enableDAP;};
      package = mkOption {
        default = haskellPackages.haskell-debug-adapter;
        type = either package (listOf str);
        description = "Haskell DAP package or command to run the Haskell DAP";
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
          ["lsp-servers"]
          ''
            vim.g.haskell_tools = {
            ${optionalString cfg.lsp.enable ''
              -- LSP
              tools = {
                hover = {
                  enable = true,
                },
              },
              hls = ${toLuaObject servers.hls},
            ''}
            ${optionalString cfg.dap.enable ''
              dap = {
                cmd = ${
                if isList cfg.dap.package
                then toLuaObject cfg.dap.package
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
