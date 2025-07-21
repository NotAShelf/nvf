{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;

  cfg = config.vim.languages.css;

  defaultServers = ["vscode-langservers-extracted"];
  servers = {
    vscode-langservers-extracted = {
      enable = true;
      cmd = [(getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server") "--stdio"];
      filetypes = ["css" "scss" "less"];
      root_markers = ["package.json" ".git"];
      capabilities = {
        # enable (broadcasting) snippet capability for completion
        # see <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls>
        textDocument.completion.completionItem.snippetSupport = true;
      };
    };
  };

  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.prettier;
    };

    prettierd = {
      package = pkgs.prettierd;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.prettier.with({
            command = "${cfg.format.package}/bin/prettierd",
          })
        )
      '';
    };

    biome = {
      package = pkgs.biome;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.biome.with({
            command = "${cfg.format.package}/bin/biome",
          })
        )
      '';
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
      servers = mkServersOption "CSS" servers defaultServers;
    };

    format = {
      enable = mkEnableOption "CSS formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "CSS formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "CSS formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
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
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.css = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
