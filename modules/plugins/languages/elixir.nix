{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.elixir;

  defaultServer = "elixirls";
  servers = {
    elixirls = {
      package = pkgs.elixir-ls;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["elixir" "eelixir" "heex" "surface"];
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${getExe cfg.lsp.package}"];
      };
    };
  };

  defaultFormat = "mix";
  formats = {
    mix = {
      package = pkgs.elixir;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.mix.with({
            command = "${cfg.format.package}/bin/mix",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";

    treesitter = {
      enable = mkEnableOption "Elixir treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "elixir";
    };

    lsp = {
      enable = mkEnableOption "Elixir LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Elixir LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Elixir LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };

      options = mkOption {
        type = lspOptions;
        default = servers.${cfg.lsp.server}.options;
        description = ''
          LSP options for Elixir language support.

          This option is freeform, you may add options that are not set by default
          and they will be merged into the final table passed to lspconfig.
        '';
      };
    };

    format = {
      enable = mkEnableOption "Elixir formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Elixir formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Elixir formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    elixir-tools = {
      enable = mkEnableOption "Elixir tools";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig = {
        enable = true;
        sources.elixir-lsp = ''
          lspconfig.${toLuaObject cfg.lsp.server}.setup(${toLuaObject cfg.lsp.options})
        '';
      };
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.elixir-format = formats.${cfg.format.type}.nullConfig;
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
