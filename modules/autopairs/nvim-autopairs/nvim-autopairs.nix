{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption mkRenamedOptionModule;
  inherit (lib.types) enum bool;
in {
  options.vim = {
    autopairs = {
      enable = mkEnableOption "autopairs" // {default = false;};

      type = mkOption {
        type = enum ["nvim-autopairs"];
        default = "nvim-autopairs";
        description = "Set the autopairs type. Options: nvim-autopairs [nvim-autopairs]";
      };

      imports = [
        (mkRenamedOptionModule ["vim" "autopairs" "nvim-compe"] ["vim" "autopairs" "nvim-compe" "setupOpts"])
      ];

      nvim-compe.setupOpts = lib.nvim.types.mkPluginSetupOption {
        map_cr = mkOption {
          type = bool;
          default = true;
          description = ''map <CR> on insert mode'';
        };

        map_complete = mkOption {
          type = bool;
          default = true;
          description = "auto insert `(` after select function or method item";
        };

        auto_select = mkOption {
          type = bool;
          default = false;
          description = "auto select first item";
        };
      };
    };
  };
}
