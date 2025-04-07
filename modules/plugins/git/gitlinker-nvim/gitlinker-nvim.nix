{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.git.gitlinker-nvim = {
    enable = mkEnableOption "gitlinker-nvim" // {default = config.vim.git.enable;};
    setupOpts = mkPluginSetupOption "gitlinker-nvim" {};
  };
}
