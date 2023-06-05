{lib, ...}:
with lib; {
  options.vim.utility.motion.hop = {
    mappings = {
      hop = mkMappingOption "Jump to occurences [hop.nvim]" "<leader>h";
    };

    enable = mkEnableOption "Hop.nvim plugin (easy motion)";
  };
}
