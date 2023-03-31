{
  lib,
  config,
  ...
}:
with lib;
with builtins; {
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

      nvim-compe = {
        map_cr = mkOption {
          type = types.bool;
          default = true;
          description = "map <CR> on insert mode";
        };

        map_complete = mkOption {
          type = types.bool;
          default = true;
          description = "auto insert `(` after select function or method item";
        };

        auto_select = mkOption {
          type = types.bool;
          default = false;
          description = "auto select first item";
        };
      };
    };
  };
}
