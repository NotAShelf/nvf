{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames isList;
  inherit (lib) genAttrs;
  inherit (lib.types) either package enum listOf str;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.meta) getExe getExe';
  inherit (pkgs) haskellPackages;

  cfg = config.vim.languages.haskell;

  defaultServers = ["haskell-language-server"];
  servers = ["haskell-language-server"];

  defaultFormat = ["ormolu"];
  formats = {
    ormolu = {command = getExe haskellPackages.ormolu;};
    fourmolu = {command = getExe haskellPackages.fourmolu;};
    stylish-haskell = {command = getExe haskellPackages.stylish-haskell;};
    floskell = {command = getExe haskellPackages.floskell;};
  };
in {
  options.vim.languages.haskell = {
    enable = mkEnableOption "Haskell support";

    treesitter = {
      enable =
        mkEnableOption "Treesitter support for Haskell"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "haskell";
    };

    lsp = {
      enable =
        mkEnableOption "Haskell LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Haskell LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Haskell formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.languages.haskell.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Haskell formatter to use";
      };
    };

    dap = {
      enable =
        mkEnableOption "DAP support for Haskell"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };
      package = mkOption {
        default = haskellPackages.haskell-debug-adapter;
        type = either package (listOf str);
        description = "Haskell DAP package or command to run the Haskell DAP";
      };
    };

    extensions = {
      haskell-tools = {
        enable = mkEnableOption "haskell-tools.nvim";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.lsp.enable && cfg.extensions.haskell-tools.enable);
          message = ''
            vim.languages.haskell: haskell-tools.nvim manages the LSP directly and
            is incompatible with vim.languages.haskell.lsp.enable. Disable one or
            the other. See https://github.com/mrcjkb/haskell-tools.nvim/blob/fe9ed6e6adfa6311e06c84569d8536190f172030/doc/haskell-tools.txt#L22
          '';
        }
        {
          assertion = !(cfg.dap.enable && !cfg.extensions.haskell-tools.enable);
          message = ''
            vim.languages.haskell: DAP support requires haskell-tools.nvim, which
            handles adapter registration and launch configuration discovery.
            Enable vim.languages.haskell.extensions.haskell-tools to use DAP.
          '';
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["haskell" "lhaskell"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            haskell = cfg.format.type;
            lhaskell = cfg.format.type;
          };
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extensions.haskell-tools.enable {
      vim = {
        extraPackages = [haskellPackages.cabal-fmt];
        startPlugins = ["haskell-tools-nvim"];
        luaConfigRC.haskell-tools-nvim = entryAfter ["lsp-servers"] ''
          vim.g.haskell_tools = {
            tools = {
              hover = {
                stylize_markdown = false,
                auto_focus = false,
              },
            },
            hls = {
              auto_attach = true,
              cmd = {"${getExe' haskellPackages.haskell-language-server "haskell-language-server-wrapper"}", "--lsp"},
              on_attach = function(client, bufnr)
                local ht = require("haskell-tools")
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', '<localleader>cl', vim.lsp.codelens.run, opts)
                vim.keymap.set('n', '<localleader>hs', ht.hoogle.hoogle_signature, opts)
                vim.keymap.set('n', '<localleader>ea', ht.lsp.buf_eval_all, opts)
                vim.keymap.set('n', '<localleader>rr', function()
                  vim.cmd('Haskell repl toggle')
                end, opts)
                vim.keymap.set('n', '<localleader>rf', function()
                  vim.cmd('Haskell repl toggle ' .. vim.api.nvim_buf_get_name(0))
                end, opts)
                vim.keymap.set('n', '<localleader>rq', function()
                  vim.cmd('Haskell repl quit')
                end, opts)
              end,
              settings = {
                haskell = {
                  formattingProvider = "none",
                  cabalFormattingProvider = "cabal-fmt",
                },
              },
            },
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
