{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) isList;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.types) either package listOf str;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption enumWithRename;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (pkgs) haskellPackages;

  cfg = config.vim.languages.haskell;

  defaultServers = [];
  servers = ["haskell-tools"];
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
        type = listOf (
          enumWithRename
          "vim.languages.haskell.lsp.servers"
          servers
          {hls = "haskell-tools";}
        );
        default = defaultServers;
        description = ''
          Haskell LSP server to use. Choosing `haskell-tools` will enable
          {option}`vim.languages.haskell.extensions.haskell-tools-nvim.enable`

          > [!NOTE]
          >
          > Since HLS is very sensitive about the GHC version, there's a very
          > high chance that the default HLS we use is not compatible with your
          > project. It is highly recommended to set
          > {option}`vim.languages.haskell.extensions.haskell-tools-nvim.setupOpts.hls.cmd`
          > to `null` and install HLS separately in a `devShell`.
        '';
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
      haskell-tools-nvim = {
        enable = mkEnableOption "advanced tools for Haskell development";
        setupOpts = mkPluginSetupOption "haskell-tools.nvim" {};
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

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["haskell" "lhaskell"];
        });
      };
    })

    (mkIf cfg.dap.enable {
      vim.languages.haskell.extensions.haskell-tools-nvim = {
        enable = true;
        setupOpts = {
          dap = {
            cmd =
              if isList cfg.dap.package
              then toLuaObject cfg.dap.package
              else ["${cfg.dap.package}/bin/haskell-debug-adapter"];
          };
        };
      };
    })

    (mkIf cfg.extensions.haskell-tools-nvim.enable {
      vim = {
        startPlugins = ["haskell-tools-nvim"];
        globals.haskell_tools = cfg.extensions.haskell-tools-nvim.setupOpts;
      };
    })
  ]);
}
