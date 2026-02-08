{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.grug-far-nvim;
in {
  config = {
    vim.lazy.plugins.grug-far-nvim = mkIf cfg.enable {
      package = "grug-far-nvim";
      cmd = [
        "GrugFar"
        "GrugFarWithin"
      ];
      setupModule = "grug-far";
      setupOpts = cfg.setupOpts;
    };
  };
}
