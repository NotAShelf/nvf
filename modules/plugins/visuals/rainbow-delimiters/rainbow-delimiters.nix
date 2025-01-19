{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.rainbow-delimiters = {
    enable = mkEnableOption "rainbow-delimiters";
    setupOpts = mkPluginSetupOption "rainbow-delimiters" {};
  };
}
