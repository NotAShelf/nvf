{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;

  cfg = config.vim.languages.cmake;

  defaultServers = ["neocmakelsp"];
  servers = ["neocmakelsp"];

  defaultFormat = ["gersemi"];
  formats = ["gersemi"];
in {
  options.vim.languages.cmake = {
    enable = mkEnableOption "CMake language support";

    treesitter = {
      enable =
        mkEnableOption "CMake treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "cmake";
    };

    lsp = {
      enable =
        mkEnableOption "CMake LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "CMake LSP servers to use";
      };
    };

    format = {
      enable =
        mkEnableOption "CMake formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "CMake formatter to use";
        type = deprecatedSingleOrListOf "vim.languages.cmake.format.type" (enum formats);
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["cmake"];
          root_markers = ["build" "cmake"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.cmake = cfg.format.type;
      };
    })
  ]);
}
