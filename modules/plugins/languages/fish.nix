{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.fish;

  defaultServers = ["fish-lsp"];
  servers = {
    fish-lsp = {
      cmd = [(getExe pkgs.fish-lsp) "start"];
      filetypes = ["fish"];
      root_markers = ["config.fish" ".git"];
    };
  };

  defaultFormat = "fish_indent";
  formats = {
    fish_indent = {
      package = pkgs.writeShellApplication {
        name = "fish_indent";
        runtimeInputs = [pkgs.fish];
        text = "fish_indent";
      };
    };
  };
in {
  options.vim.languages.fish = {
    enable = mkEnableOption "Fish language support";
    treesitter = {
      enable = mkEnableOption "Fish treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "fish";
    };

    lsp = {
      enable = mkEnableOption "Fish LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Fish LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Fish formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Fish formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Fish formatter package";
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.fish = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
