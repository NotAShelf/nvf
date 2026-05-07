{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.types) either package enum listOf str;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.custom) enumWithRename;
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
          (attrNames servers)
          {hls = "haskell-tools";}
        );
        default = defaultServers;
        description = ''
          Haskell LSP server to use. Choosing `haskell-tools` will enable
          {option}`vim.languages.haskell.extensions.haskell-tools-nvim.enable`

          > [!NOTE]
          >
          > HLS is extremely picky about your GHC version - most likely you'll
          > have to install your specific HLS version in a devShell that matches
          > your GHC version.
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
        luaConfigRC.haskell-tools-nvim =
          entryAfter
          ["lsp-servers"]
          ''
            vim.g.haskell_tools = ${cfg.extensions.haskell-tools-nvim.setupOpts}
          '';
      };
    })
  ]);
}
