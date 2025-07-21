{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) package enum;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;

  defaultServers = ["fsautocomplete"];
  servers = {
    fsautocomplete = {
      enable = true;
      cmd = [(getExe pkgs.fsautocomplete)];
      filetypes = ["fsharp"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('*.sln', '*.fsproj', '.git')(fname))
          end,
        '';
    };
  };

  defaultFormat = "fantomas";
  formats = {
    fantomas = {
      package = pkgs.fantomas;
    };
  };

  cfg = config.vim.languages.fsharp;
in {
  options = {
    vim.languages.fsharp = {
      enable = mkEnableOption "F# language support";

      treesitter = {
        enable = mkEnableOption "F# treesitter" // {default = config.vim.languages.enableTreesitter;};
        package = mkGrammarOption pkgs "fsharp";
      };

      lsp = {
        enable = mkEnableOption "F# LSP support" // {default = config.vim.lsp.enable;};
        servers = mkServersOption "F#" servers defaultServers;
      };

      format = {
        enable = mkEnableOption "F# formatting" // {default = config.vim.languages.enableFormat;};

        type = mkOption {
          type = enum (attrNames formats);
          default = defaultFormat;
          description = "F# formatter to use";
        };

        package = mkOption {
          type = package;
          default = formats.${cfg.format.type}.package;
          description = "F# formatter package";
        };
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
        setupOpts.formatters_by_ft.fsharp = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
