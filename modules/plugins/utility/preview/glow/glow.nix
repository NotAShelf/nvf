{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "languages" "markdown" "glow" "enable"] ["vim" "utility" "preview" "glow" "enable"])
  ];

  options.vim.utility.preview = {
    glow = {
      enable = mkEnableOption "markdown preview in neovim with glow";
      mappings.openPreview = mkMappingOption config.vim.enableNvfKeymaps "Open preview" "<leader>p";
    };
  };
}
