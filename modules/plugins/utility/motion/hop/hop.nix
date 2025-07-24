{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.motion.hop = {
    mappings = {
      hop = mkMappingOption config.vim.enableNvfKeymaps "Jump to occurrences [hop.nvim]" "<leader>h";
    };

    enable = mkEnableOption "Hop.nvim plugin (easy motion)";
  };
}
