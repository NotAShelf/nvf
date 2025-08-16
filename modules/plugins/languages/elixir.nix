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
  inherit (lib.types) enum package;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.elixir;

  defaultServers = ["elixirls"];
  servers = {
    elixirls = {
      enable = true;
      cmd = [(getExe pkgs.elixir-ls)];
      filetypes = ["elixir" "eelixir" "heex" "surface"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local matches = vim.fs.find({ 'mix.exs' }, { upward = true, limit = 2, path = fname })
            local child_or_root_path, maybe_umbrella_path = unpack(matches)
            local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

            on_dir(root_dir)
          end
        '';
    };
  };

  defaultFormat = "mix";
  formats = {
    mix = {
      package = pkgs.elixir;
      config = {
        command = "${cfg.format.package}/bin/mix";
      };
    };
  };
in {
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";

    treesitter = {
      enable = mkEnableOption "Elixir treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "elixir";
      heexPackage = mkGrammarOption pkgs "heex";
      eexPackage = mkGrammarOption pkgs "eex";
    };

    lsp = {
      enable = mkEnableOption "Elixir LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Elixir LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Elixir formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Elixir formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Elixir formatter package";
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
        setupOpts.formatters_by_ft.elixir = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} =
          formats.${cfg.format.type}.config;
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
