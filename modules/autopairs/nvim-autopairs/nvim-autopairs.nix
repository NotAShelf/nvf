{lib, ...}: let
  inherit (lib) mkRemovedOptionModule;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum;
in {
  imports = [
    (mkRemovedOptionModule ["vim" "autopairs" "nvim-compe"] "nvim-compe is deprecated and no longer suported.")
  ];

  options.vim = {
    autopairs = {
      enable = mkEnableOption "autopairs" // {default = false;};

      type = mkOption {
        type = enum ["nvim-autopairs"];
        default = "nvim-autopairs";
        description = "Set the autopairs type. Options: nvim-autopairs [nvim-autopairs]";
      };
    };
  };
}
