{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib.attrsets) attrNames genAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.assembly;
  defaultServers = ["asm-lsp"];
  servers = ["asm-lsp"];

  defaultFormat = ["asmfmt"];
  formats = {
    asmfmt = {
      command = getExe pkgs.asmfmt;
    };
    nasmfmt = {
      command = getExe pkgs.nasmfmt;
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--ii", ctx.shiftwidth,
            "$FILENAME",
          }
        end
      '';
    };
  };
in {
  options.vim.languages.assembly = {
    enable = mkEnableOption "Assembly support";

    treesitter = {
      enable =
        mkEnableOption "Assembly treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      packageASM = mkGrammarOption pkgs "asm";
      packageNASM = mkGrammarOption pkgs "nasm";
      packageRpiPicoASM = mkGrammarOption pkgs "pioasm";
    };

    lsp = {
      enable =
        mkEnableOption "Assembly LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Assembly LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Assembly formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "Assembly formatter to use";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.packageASM
        cfg.treesitter.packageNASM
        cfg.treesitter.packageRpiPicoASM
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "asm"
            "nasm"
            "masm"
            "vmasm"
            "fasm"
            "tasm"
            "tiasm"
            "asm68k"
            "asmh8300"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            asm = cfg.format.type;
            nasm = cfg.format.type;
            masm = cfg.format.type;
            vmasm = cfg.format.type;
            tasm = cfg.format.type;
            tiasm = cfg.format.type;
            asm68k = cfg.format.type;
            asmh8300 = cfg.format.type;
          };
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
