{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.crazy-coverage;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins = {
      "crazy-coverage" = {
        package = "crazy-coverage";
        setupModule = "crazy-coverage";
        cmd = [
          "CoverageToggle"
          "CoverageToggleHitCount"
          "CoverageToggleSignColumn"
          "CoverageToggleBranchOverlay"
          "CoverageToggleRegionOverlay"
          "CoverageToggleNvimTree"
          "CoverageToggleNeoTree"
          "CoverageLoad"
          "CoverageSummary"
          "CrazyCoverageSummary"
          "CoverageNextCovered"
          "CoveragePrevCovered"
          "CoverageNextUncovered"
          "CoveragePrevUncovered"
          "CoverageNextPartial"
          "CoveragePrevPartial"
        ];
        inherit (cfg) setupOpts;
      };
    };
  };
}
