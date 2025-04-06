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
  inherit (lib.lists) isList;
  inherit (lib.types) bool either enum listOf package str;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.fish;

  defaultFormat = "fish_indent";

  formats = {
    fish_indent = {
      cmd = "${pkgs.fish}/bin/fish_indent";
    };
  };
in {
  options.vim.languages.fish = {
    enable = mkEnableOption "Fish language support";

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable Fish formatting";
      };

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Fish formatter to use";
      };

      cmd = mkOption {
        type = str;
        default = formats.${cfg.format.type}.cmd;
        description = "Path to fish formatter executable";
      };
    };

    lsp = {
      enable = mkEnableOption "Fish LSP support via fish-lsp" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "fish-lsp package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.fish-lsp;
      };
    };

    treesitter = {
      enable = mkEnableOption "Fish Treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "fish";
    };
  };

  config = mkMerge [
    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.fish = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {command = cfg.format.cmd;};
      };
    })

    (mkIf (cfg.enable && cfg.lsp.enable) {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.fish-lsp = let
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else toLuaObject ["${getExe cfg.lsp.package}" "start"];
      in ''
        lspconfig.fish_lsp.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${cmd};
        }
      '';
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ];
}
