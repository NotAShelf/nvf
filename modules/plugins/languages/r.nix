{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.generators) mkLuaInline;

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

  defaultServers = ["r_language_server"];
  servers = {
    r_language_server = {
      enable = true;
      cmd = [(getExe r-with-languageserver) "--no-echo" "-e" "languageserver::run()"];
      filetypes = ["r" "rmd" "quarto"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, '.git') or vim.uv.os_homedir())
        end
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

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "R LSP server to use";
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
