{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.ccc = {
    enable = mkEnableOption "ccc color picker for neovim";

    mappings = {
      quit = mkMappingOption config.vim.enableNvfKeymaps "Cancel and close the UI without replace or insert" "<Esc>";
      increase10 = mkMappingOption config.vim.enableNvfKeymaps "Increase the value times delta of the slider" "<L>";
      decrease10 = mkMappingOption config.vim.enableNvfKeymaps "Decrease the value times delta of the slider" "<H>";
    };
  };
}
