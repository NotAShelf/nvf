{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key keybind helper menu";
  };
}
