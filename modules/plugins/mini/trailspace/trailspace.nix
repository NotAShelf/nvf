{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.trailspace = {
    enable = mkEnableOption "mini.trailspace";
    setupOpts = mkPluginSetupOption "mini.trailspace" {};
  };
}
