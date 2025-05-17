{lib, ...}: let
  inherit (lib.options) mkEnableOption;

  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.images.img-clip = {
    enable = mkEnableOption "img-clip to paste images into any markup language";

    setupOpts = mkPluginSetupOption "img-clip" {};
  };
}
