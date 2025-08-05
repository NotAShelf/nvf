{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

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
      config = {
        command = "${cfg.format.package}/bin/R";
      };
    };

    format_r = {
      package = pkgs.rWrapper.override {
        packages = [pkgs.rPackages.formatR];
      };
      config = {
        command = "${cfg.format.package}/bin/R";
        stdin = true;
        args = [
          "--slave"
          "--no-restore"
          "--no-save"
          "-s"
          "-e"
          ''formatR::tidy_source(source="stdin")''
        ];
        # TODO: range_args seem to be possible
        # https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/formatting/format_r.lua
      };
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
      package = mkGrammarOption pkgs "r";
    };

    lsp = {
      enable = mkEnableOption "R LSP support" // {default = config.vim.lsp.enable;};

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
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.r = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = formats.${cfg.format.type}.config;
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.r-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
