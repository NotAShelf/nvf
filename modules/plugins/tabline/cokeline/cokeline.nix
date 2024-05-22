{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.tabline.cokeline = {
    enable = mkEnableOption "cokeline";

    mappings = {
      cycleNext = mkMappingOption "Next buffer" "<Tab>";
      cyclePrevious = mkMappingOption "Previous buffer" "<S-Tab>";
      pick = mkMappingOption "Pick buffer" "<leader>bc";
      switchNext = mkMappingOption "Switch with next buffer" "<leader>bmn";
      switchPrevious = mkMappingOption "Move previous buffer" "<leader>bmp";
      closeByLetter = mkMappingOption "Close buffer by letter" "<leader>bd";
    };
  };
}
