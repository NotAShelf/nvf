{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) enum listOf;
  inherit (lib.attrsets) attrNames genAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkTreesitterGrammarOption;

  cfg = config.vim.languages.standard-ml;

  defaultServers = ["millet"];
  servers = ["millet"];

  defaultFormat = ["smlfmt"];
  formats = {
    smlfmt = {
      command = getExe pkgs.smlfmt;
      stdin = false;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--force",
            "-tab-width", ctx.shiftwidth,
            "-indent-width", ctx.shiftwidth,
            "$FILENAME",
          }
        end
      '';
    };
  };
in {
  options.vim.languages.standard-ml = {
    enable = mkEnableOption "Standard ML support";

    treesitter = {
      enable =
        mkEnableOption "Standard ML treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkTreesitterGrammarOption pkgs "sml";
    };

    lsp = {
      enable =
        mkEnableOption "Standard ML LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Standard ML LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Standard ML formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Standard ML formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["sml"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.sml = cfg.format.type;
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
