{lib, ...}:
with lib;
with builtins; {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key keybind helper menu";
  };
}
