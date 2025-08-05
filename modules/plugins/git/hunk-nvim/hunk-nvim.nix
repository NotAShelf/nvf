{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.git.hunk-nvim = {
    enable = mkEnableOption "tool for splitting diffs in Neovim [hunk-nvim]" // {default = config.vim.git.enable;};
    setupOpts = mkPluginSetupOption "hunk-nvim" {};
  };
}
