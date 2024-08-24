{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) lznPluginType;
in {
  options.vim.lazy = {
    enable = mkEnableOption "plugin lazy-loading" // {default = true;};
    loader = mkOption {
      description = "Lazy loader to use";
      type = enum ["lz.n"];
      default = "lz.n";
    };

    plugins = mkOption {
      default = [];
      type = listOf lznPluginType;
      description = "list of plugins to lazy load";
      example = ''
        [
          {
            package = "toggleterm-nvim";
            after = lib.generators.mkLuaInline "function() require('toggleterm').setup{} end";
            cmd = ["ToggleTerm"];
          }
        ]
      '';
    };
  };
}
