{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.tabline.nvimBufferline = {
    enable = mkEnableOption "neovim bufferline";

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
