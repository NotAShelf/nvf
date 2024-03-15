{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.types) listOf package;
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";
    fold = mkEnableOption "fold with treesitter";
    autotagHtml = mkEnableOption "autoclose and rename html tag";
    grammars = mkOption {
      type = listOf package;
      default = [];
      description = ''
        List of treesitter grammars to install. For supported languages
        use the `vim.language.<lang>.treesitter` option
      '';
    };

    mappings.incrementalSelection = {
      init = mkMappingOption "Init selection [treesitter]" "gnn";
      incrementByNode = mkMappingOption "Increment selection by node [treesitter]" "grn";
      incrementByScope = mkMappingOption "Increment selection by scope [treesitter]" "grc";
      decrementByNode = mkMappingOption "Decrement selection by node [treesitter]" "grm";
    };
  };
}
