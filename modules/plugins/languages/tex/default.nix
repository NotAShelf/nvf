{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool str;

  cfg = config.vim.languages.tex;
in {
  imports = [
    ./treesitter.nix
    ./lsp
    ./build
  ];

  options.vim.languages.tex = {
    enable = mkEnableOption "Tex support";

    extraOpts = {
      texFlavor = {
        enable = mkOption {
          type = bool;
          default = false;
          example = true;
          description = ''
            Whether to set the vim.g.tex_flavor (g:tex_flavor) option in your lua config.

            When opening a .tex file vim will try to automatically try to determine the file type from
            the three options: plaintex (for plain TeX), context (for ConTeXt), or tex (for LaTeX).
            This can either be done by a indicator line of the form `%&<format>` on the first line or
            if absent vim will search the file for keywords to try and determine the filetype.
            If no filetype can be determined automatically then by default it will fallback to plaintex.

            This option will enable setting the tex flavor in your lua config and you can set its value
            useing the `vim.languages.tex.lsp.extraOpts.texFlavor.flavor = <flavor>` in your nvf config.

            Setting this option to `false` will omit the `vim.g.tex_flavor = <flavor>` line from your lua
            config entirely (unless you manually set it elsewhere of course).
          '';
        };
        flavor = mkOption {
          type = str;
          default = "plaintex";
          example = "tex";
          description = ''
            The flavor to set as a fallback for when vim cannot automatically determine the tex flavor when
            opening a .tex document.

            The options are: plaintex (for plain TeX), context (for ConTeXt), or tex (for LaTeX).

            This can be particularly useful for when using `vim.utility.new-file-template` options for
            creating templates when no context has yet been added to a new file.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Extra Lua config options
    (mkIf cfg.extraOpts.texFlavor.enable {
      vim.globals.tex_flavor = "${cfg.extraOpts.texFlavor.flavor}";
    })
  ]);
}
