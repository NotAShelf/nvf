{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) lznPluginTableType;
in {
  options.vim.lazy = {
    enable = mkEnableOption "plugin lazy-loading" // {default = true;};
    loader = mkOption {
      description = "Lazy loader to use";
      type = enum ["lz.n"];
      default = "lz.n";
    };

    plugins = mkOption {
      default = {};
      type = lznPluginTableType;
      description = "list of plugins to lazy load";
      example = ''
        {
          toggleterm-nvim = {
            package = "toggleterm-nvim";
            after = lib.generators.mkLuaInline "function() require('toggleterm').setup{} end";
            cmd = ["ToggleTerm"];
          };
        }
      '';
    };
  };
}
