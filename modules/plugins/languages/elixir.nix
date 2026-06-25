{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.elixir;

  defaultServers = ["elixir-ls"];
  servers = ["elixir-ls"];

  defaultFormat = ["mix"];
  formats = {
    mix = {
      command = "${pkgs.elixir}/bin/mix";
    };
  };
in {
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";

    treesitter = {
      enable =
        mkEnableOption "Elixir treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "elixir";
      heexPackage = mkGrammarOption pkgs "heex";
      eexPackage = mkGrammarOption pkgs "eex";
    };

    lsp = {
      enable =
        mkEnableOption "Elixir LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.elixir.lsp.servers"
          servers
          {
            elixirls = "elixir-ls";
          });
        default = defaultServers;
        description = "Elixir LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Elixir formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.elixir.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Elixir formatter to use";
      };
    };

    elixir-tools = {
      enable = mkEnableOption "Elixir tools";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.package
        cfg.treesitter.heexPackage
        cfg.treesitter.eexPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["elixir" "eelixir" "heex" "surface"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.elixir = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.elixir-tools.enable {
      vim.startPlugins = ["elixir-tools-nvim"];
      vim.pluginRC.elixir-tools = entryAnywhere ''
        local elixir = require("elixir")
        local elixirls = require("elixir.elixirls")

        -- disable imperative insstallations of various
        -- elixir related tools installed by elixir-tools
        elixir.setup {
          nextls = {
            enable = false -- defaults to false
          },

          credo = {
            enable = false -- defaults to true
          },

          elixirls = {
            enable = false, -- defaults to true
          }
        }
      '';
    })
  ]);
}
