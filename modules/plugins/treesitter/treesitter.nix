{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.types) listOf package;

  inherit (pkgs.vimPlugins.nvim-treesitter) builtGrammars;
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    mappings.incrementalSelection = {
      init = mkMappingOption "Init selection [treesitter]" "gnn";
      incrementByNode = mkMappingOption "Increment selection by node [treesitter]" "grn";
      incrementByScope = mkMappingOption "Increment selection by scope [treesitter]" "grc";
      decrementByNode = mkMappingOption "Decrement selection by node [treesitter]" "grm";
    };

    fold = mkEnableOption "fold with treesitter";
    autotagHtml = mkEnableOption "autoclose and rename html tag";
    grammars = mkOption {
      type = listOf package;
      default = [];
      description = ''
        List of treesitter grammars to install.

        For languages already supported by neovim-flake, you may
        use the {option}`vim.language.<lang>.treesitter` options, which
        will automatically add the required grammars to this.
      '';
    };

    defaultGrammars = mkOption {
      internal = true;
      readOnly = true;
      type = listOf package;
      default = with builtGrammars; [c lua vim vimdoc query];
      description = ''
        A list of treesitter grammars that will be installed by default
        if treesitter has been enabled.

        ::: {.warning}
        Regardless of which language module options you enable, Neovim
        depends on those grammars to be enabled while treesitter is enabled.
        This list cannot be modified, but its contents will only be appended
        if the list of grammars does not contain the required grammars.
        :::
      '';
    };
  };
}
