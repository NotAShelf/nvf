{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption;
in {
  options.vim.tabline.nvimBufferline = {
    enable = mkEnableOption "nvim-bufferline-lua as a bufferline";

    mappings = {
      closeCurrent = mkMappingOption "Close buffer" null;
      cycleNext = mkMappingOption "Next buffer" "<leader>bn";
      cyclePrevious = mkMappingOption "Previous buffer" "<leader>bp";
      pick = mkMappingOption "Pick buffer" "<leader>bc";
      sortByExtension = mkMappingOption "Sort buffers by extension" "<leader>bse";
      sortByDirectory = mkMappingOption "Sort buffers by directory" "<leader>bsd";
      sortById = mkMappingOption "Sort buffers by ID" "<leader>bsi";
      moveNext = mkMappingOption "Move next buffer" "<leader>bmn";
      movePrevious = mkMappingOption "Move previous buffer" "<leader>bmp";
    };
  };
}
