{lib, ...}:
with lib;
with builtins; {
  options.vim.utility.ccc = {
    enable = mkEnableOption "Enable ccc color picker for neovim";

    mappings = {
      quit = mkMappingOption "Cancel and close the UI without replace or insert" "<Esc>";
      increase10 = mkMappingOption "Increase the value times delta of the slider" "<L>";
      decrease10 = mkMappingOption "Decrease the value times delta of the slider" "<H>";
    };
  };
}
