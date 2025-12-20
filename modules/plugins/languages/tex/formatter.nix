{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalMD;
  inherit (lib.nvim.types) deprecatedSingleOrListOf;
  inherit (lib.attrsets) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.tex;

  defaultFormat = ["latexindent"];

  formats = {
    latexindent = {
      command = "${pkgs.texlive.withPackages (ps: [ps.latexindent])}/bin/latexindent";
    };
  };
in {
  options.vim.languages.tex.format = {
    enable =
      mkEnableOption "TeX formatting"
      // {
        default = !cfg.lsp.enable && config.vim.languages.enableFormat;
        defaultText = literalMD ''
          diabled if TeX LSP is enabled, otherwise follows {option}`vim.languages.enableFormat`
        '';
      };

    type = mkOption {
      description = "TeX formatter to use";
      type = with lib.types; deprecatedSingleOrListOf "vim.language.tex.format.type" (enum (attrNames formats));
      default = defaultFormat;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.tex = cfg.format.type;
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
