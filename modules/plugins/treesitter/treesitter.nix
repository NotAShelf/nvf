{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) listOf package bool;
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    fold = mkEnableOption "fold with treesitter";
    autotagHtml = mkEnableOption "autoclose and rename html tag";

    grammars = mkOption {
      type = listOf package;
      default = [];
      example = literalExpression ''
        with pkgs.vimPlugins.nvim-treesitter.parsers; [
          regex
          kdl
        ];
      '';
      description = ''
        List of treesitter grammars to install. For grammars to be installed properly,
        you must use grammars from `pkgs.vimPlugins.nvim-treesitter.parsers` or `pkgs.vimPlugins.nvim-treesitter.grammarPlugins`.
        You can use `pkgs.vimPlugins.nvim-treesitter.allGrammars` to install all grammars.

        For languages already supported by nvf, you may use
        {option}`vim.language.<lang>.treesitter` options, which will automatically add
        the required grammars to this.
      '';
    };

    addDefaultGrammars = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether to add the default grammars to the list of grammars
        to install.

        This option is only relevant if treesitter has been enabled.
      '';
    };

    defaultGrammars = mkOption {
      internal = true;
      readOnly = true;
      type = listOf package;
      default = with pkgs.vimPlugins.nvim-treesitter.parsers; [c lua vim vimdoc query];
      description = ''
        A list of treesitter grammars that will be installed by default
        if treesitter has been enabled and  {option}`vim.treeesitter.addDefaultGrammars`
        has been set to true.

        ::: {.note}
        Regardless of which language module options you enable, Neovim
        depends on those grammars to be enabled while treesitter is enabled.

        This list cannot be modified, but if you would like to bring your own
        parsers instead of those provided here, you can set `addDefaultGrammars`
        to false
        :::
      '';
    };

    indent = {enable = mkEnableOption "indentation with treesitter" // {default = true;};};
    highlight = {enable = mkEnableOption "highlighting with treesitter" // {default = true;};};
  };
}
