{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.utility.outline.aerial-nvim;
  inherit (options.vim.utility.outline.aerial-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.aerial-nvim = {
        package = "aerial-nvim";

        setupModule = "aerial";
        inherit (cfg) setupOpts;

        cmd = [
          "AerialClose"
          "AerialCloseAll"
          "AerialGo"
          "AerialInfo"
          "AerialNavClose"
          "AerialNavOpen"
          "AerialNavToggle"
          "AerialNext"
          "AerialOpen"
          "AerialOpenAll"
          "AerialPrev"
          "AerialToggle"
        ];

        keys = [
          (mkKeymap "n" cfg.mappings.toggle ":AerialToggle<CR>" {desc = mappings.toggle.description;})
        ];
      };
    };
  };
}
