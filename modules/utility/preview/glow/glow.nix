{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption;
in {
  options.vim.utility.preview = {
    glow = {
      enable = mkEnableOption "enable markdown preview in neovim with glow";
      mappings = {
        openPreview = mkMappingOption "Open preview" "<leader>p";
      };
    };
  };
}
