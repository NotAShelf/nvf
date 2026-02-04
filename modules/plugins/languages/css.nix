{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.css;

  defaultServer = ["cssls"];
  servers = {
    cssls = {
      cmd = ["${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server" "--stdio"];
      filetypes = ["css" "less"];
      # needed to enable formatting
      init_options = {provideFormatter = true;};
      root_markers = [".git" "package.json"];
      settings = {
        css.validate = true;
        less.validate = true;
      };
    };
  };

  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.prettier;
    };

    prettierd = {
      command = getExe pkgs.prettierd;
    };

    biome = {
      command = getExe pkgs.biome;
    };
  };
in {
  options.vim.languages.css = {
    enable = mkEnableOption "CSS language support";

    treesitter = {
      enable = mkEnableOption "CSS treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkGrammarOption pkgs "css";
    };

    lsp = {
      enable = mkEnableOption "CSS LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.css.lsp.servers" (enum (attrNames servers));
        default = defaultServer;
        description = "CSS LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "CSS formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "CSS formatter to use";
        type = deprecatedSingleOrListOf "vim.language.css.format.type" (enum (attrNames formats));
        default = defaultFormat;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.css = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
