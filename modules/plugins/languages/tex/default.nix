{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum nullOr;

  cfg = config.vim.languages.tex;
in {
  imports = [
    ./formatter.nix
    ./lsp.nix
    ./treesitter.nix
  ];

  options.vim.languages.tex = {
    enable = mkEnableOption "Tex support";

    flavor = mkOption {
      type = nullOr (enum [
        "plaintex"
        "context"
        "tex"
      ]);
      default = "plaintex";
      example = "tex";
      description = ''
        The flavor to set as a fallback for when vim cannot automatically
        determine the tex flavor when opening a `.tex` document.

        See `:help g:tex_flavor` for details
      '';
    };
  };

  config = {
    vim.globals.tex_flavor = lib.mkDefault "${cfg.flavor}";
  };
}
