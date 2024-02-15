{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption mkRenamedOptionModule;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "languages" "markdown" "glow" "enable"] ["vim" "utility" "preview" "glow" "enable"])
  ];

  options.vim.utility.preview = {
    glow = {
      enable = mkEnableOption "markdown preview in neovim with glow";
      mappings.openPreview = mkMappingOption "Open preview" "<leader>p";
    };
  };
}
