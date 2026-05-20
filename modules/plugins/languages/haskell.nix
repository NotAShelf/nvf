{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) genAttrs optional;
  inherit (lib.types) either package enum listOf str nullOr attrsOf anything;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (config.vim.lib) mkMappingOption;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) addDescriptionsToMappings;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption luaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
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

  defaultCabalFormat = "cabal-fmt";
  cabalFormats = {
    cabal-fmt = haskellPackages.cabal-fmt;
    cabal-gild = haskellPackages.cabal-gild;
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
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "Haskell formatter to use";
      };
    };

    cabalFormat = {
      enable =
        mkEnableOption "Haskell cabal file formatting via HLS"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = enum (attrNames cabalFormats);
        default = defaultCabalFormat;
        description = "Haskell cabal file formatter to use via HLS";
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

        mappings = {
          codeLensRun = mkMappingOption "Run code lens [haskell-tools.nvim]" "<localleader>cl";
          hoogleSignature = mkMappingOption "Hoogle signature [haskell-tools.nvim]" "<localleader>hs";
          evalAll = mkMappingOption "Evaluate all [haskell-tools.nvim]" "<localleader>ea";
          replToggle = mkMappingOption "Toggle REPL [haskell-tools.nvim]" "<localleader>rr";
          replToggleFile = mkMappingOption "Toggle REPL for current file [haskell-tools.nvim]" "<localleader>rf";
          replQuit = mkMappingOption "Quit REPL [haskell-tools.nvim]" "<localleader>rq";
        };

        setupOpts = mkPluginSetupOption "haskell-tools.nvim" {
          hls = {
            cmd = mkOption {
              type = nullOr (listOf str);
              default = [
                "${pkgs.haskellPackages.haskell-language-server}/bin/haskell-language-server-wrapper"
                "--lsp"
              ];
              description = "Command for haskell-language-server.";
            };
            on_attach = mkOption {
              type = nullOr luaInline;
              description = "Function to run when HLS is attached. When null, mappings from the mappings option are used.";
              default = null;
              defaultText = literalExpression "Generated from vim.languages.haskell.extensions.haskell-tools.mappings";
            };

            settings = mkOption {
              type = nullOr (attrsOf anything);
              default = null;
              description = "Settings passed to HLS. When null, generated from vim.languages.haskell.cabalFormat.";
            };
          };

          dap = {
            cmd = mkOption {
              type = nullOr (listOf str);
              default = null;
              description = "Debug adapter command";
            };
          };
        };
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
        extraPackages = optional cfg.cabalFormat.enable cabalFormats.${cfg.cabalFormat.type};
        startPlugins = ["haskell-tools-nvim"];
        globals.haskell_tools = cfg.extensions.haskell-tools.setupOpts;
        languages.haskell.extensions.haskell-tools.setupOpts = {
          hls = {
            on_attach = let
              htCfg = cfg.extensions.haskell-tools;
              keymapDefinitions = options.vim.languages.haskell.extensions.haskell-tools.mappings;
              mappings = addDescriptionsToMappings htCfg.mappings keymapDefinitions;
              mkBinding = binding: action:
                if binding.value != null
                then "vim.keymap.set('n', ${toLuaObject binding.value}, ${action}, {buffer=bufnr, noremap=true, silent=true, desc=${toLuaObject binding.description}})"
                else "";
            in
              mkLuaInline ''
                function(client, bufnr)
                  local ht = require("haskell-tools")
                  ${mkBinding mappings.codeLensRun "vim.lsp.codelens.run"}
                  ${mkBinding mappings.hoogleSignature "ht.hoogle.hoogle_signature"}
                  ${mkBinding mappings.evalAll "ht.lsp.buf_eval_all"}
                  ${mkBinding mappings.replToggle "function() vim.cmd('Haskell repl toggle') end"}
                  ${mkBinding mappings.replToggleFile "function() vim.cmd('Haskell repl toggle ' .. vim.api.nvim_buf_get_name(0)) end"}
                  ${mkBinding mappings.replQuit "function() vim.cmd('Haskell repl quit') end"}
                end
              '';
            settings = mkIf cfg.cabalFormat.enable (mkDefault {
              haskell = {
                cabalFormattingProvider = cfg.cabalFormat.type;
                plugin.${cfg.cabalFormat.type}.config.path = getExe cabalFormats.${cfg.cabalFormat.type};
              };
            });
          };
        };
      };
    })
  ]);
}
