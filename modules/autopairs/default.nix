{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autopairs;
in {
  options.vim = {
    autopairs = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable autopairs";
      };

      type = mkOption {
        type = types.enum ["nvim-autopairs"];
        default = "nvim-autopairs";
        description = "Set the autopairs type. Options: nvim-autopairs [nvim-autopairs]";
      };
    };
  };

  config =
    mkIf cfg.enable
    {
      vim.startPlugins = ["nvim-autopairs"];

      vim.luaConfigRC.autopairs = nvim.dag.entryAnywhere ''
        require("nvim-autopairs").setup{}
        ${optionalString (config.vim.autocomplete.type == "nvim-compe") ''
          require('nvim-autopairs.completion.compe').setup({
            map_cr = true,
            map_complete = true,
            auto_select = false,
          })
        ''}
      '';
    };
}
