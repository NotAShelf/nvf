{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf package;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.cmake;

  defaultServers = ["neocmakelsp"];
  servers = {
    neocmakelsp = {
      enable = true;
      cmd = [(getExe pkgs.neocmakelsp) "--stdio"];
      filetypes = ["cmake"];
      root_markers = [".gersemirc" ".git" "build" "cmake"];
      capabilities = {
        textDocument.completion.completionItem.snippetSupport = true;
      };
    };
  };

  defaultFormat = "gersemi";
  formats = {
    gersemi = {
      package = pkgs.gersemi;
    };
  };
in {
  options.vim.languages.cmake = {
    enable = mkEnableOption "CMake language support";

    treesitter = {
      enable = mkEnableOption "CMake treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "cmake";
    };

    lsp = {
      enable = mkEnableOption "CMake LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "CMake LSP servers to use";
      };
    };

    format = {
      enable = mkEnableOption "CMake formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "CMake formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "CMake formatter package";
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
        setupOpts.formatters_by_ft.cmake = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
