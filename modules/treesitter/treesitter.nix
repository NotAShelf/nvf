{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption mkOption types;
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    fold = mkEnableOption "fold with treesitter";

    autotagHtml = mkEnableOption "autoclose and rename html tag";

    mappings = {
      incrementalSelection = {
        init = mkMappingOption "Init selection [treesitter]" "gnn";
        incrementByNode = mkMappingOption "Increment selection by node [treesitter]" "grn";
        incrementByScope = mkMappingOption "Increment selection by scope [treesitter]" "grc";
        decrementByNode = mkMappingOption "Decrement selection by node [treesitter]" "grm";
      };
    };

    grammars = mkOption {
      type = with types; listOf package;
      default = [];
      description = ''
        List of treesitter grammars to install. For supported languages
        use the `vim.language.<lang>.treesitter` option
      '';
    };
  };
}
