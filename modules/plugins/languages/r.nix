{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str nullOr attrsOf;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.r;

  r-with-languageserver = pkgs.rWrapper.override {
    packages = [pkgs.rPackages.languageserver];
  };

  defaultFormat = "format_r";
  formats = {
    styler = {
      package = pkgs.rWrapper.override {
        packages = [pkgs.rPackages.styler];
      };
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.styler.with({
            command = "${cfg.format.package}/bin/R",
          })
        )
      '';
    };

    format_r = {
      package = pkgs.rWrapper.override {
        packages = [pkgs.rPackages.formatR];
      };
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.format_r.with({
            command = "${cfg.format.package}/bin/R",
          })
        )
      '';
    };
  };

  defaultServer = "r_language_server";
  servers = {
    r_language_server = {
      package = pkgs.writeShellScriptBin "r_lsp" ''
        ${r-with-languageserver}/bin/R --slave -e "languageserver::run()"
      '';
      lspConfig = ''
        lspconfig.r_language_server.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${lib.getExe cfg.lsp.package}"}''
        }
        }
      '';
    };
  };
in {
  options.vim.languages.r = {
    enable = mkEnableOption "R language support";

    treesitter = {
      enable = mkEnableOption "R treesitter" // {default = config.vim.languages.enableTreesitter;};
      rPackage = mkGrammarOption pkgs "r";
      rnowebPackage = mkGrammarOption pkgs "rnoweb";
      mdPackage = mkGrammarOption pkgs "markdown";
      mdInlinePackage = mkGrammarOption pkgs "markdown-inline";
      yamlPackage = mkGrammarOption pkgs "yaml";
      csvPackage = mkGrammarOption pkgs "csv";
    };

    lsp = {
      enable = mkEnableOption "R LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "R LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "R LSP server package, or the command to run as a list of strings";
        example = literalExpression "[ (lib.getExe pkgs.jdt-language-server) \"-data\" \"~/.cache/jdtls/workspace\" ]";
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "R formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "R formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "R formatter package";
      };
    };

    extensions = {
      R-nvim = {
        enable =
          mkEnableOption ''
            [R.nvim]: https://github.com/R-Nvim/R.nvim

            R.nvim adds R support to Neovim, including:

              - Communication with R via Neovim's built-in terminal or tmux
              - A built-in object explorer and autocompletions built from your R environment
              - Keyboard shortcuts for common inserts like <- and |>
              - Quarto/R Markdown support
          ''
          // {default = true;};

        setupOpts = mkPluginSetupOption "R-nvim" {};
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.r-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.r-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.rPackage
        cfg.treesitter.rnowebPackage
        cfg.treesitter.mdPackage
        cfg.treesitter.mdInlinePackage
        cfg.treesitter.yamlPackage
        cfg.treesitter.csvPackage
      ];
    })

    (mkIf cfg.extensions.R-nvim.enable {
      vim.startPlugins = ["R-nvim"];
      vim.pluginRC.R-nvim= entryAnywhere ''
        require("r").setup(${toLuaObject cfg.extensions.R-nvim.setupOpts})
      '';
    })
  ]);
}
