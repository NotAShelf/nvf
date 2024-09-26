{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.ui.edgy-nvim = {
    enable = mkEnableOption "edgy.nvim for predefined window layouts";
    setRecommendedNeovimOpts = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether nvf should set `vim.opt.laststatus` and `vim.opt.splitkeep` to
        values recommended by upstream to ensure maximum compatibility.
      '';
    };

    setupOpts = mkPluginSetupOption "edgy" {
      animate.enabled = mkEnableOption "animation support. Requires an animation library such as `mini.animate`";
    };
  };
}
