{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.twilight-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.twilight-nvim = {
      package = "twilight-nvim";
      setupModule = "twilight";
      inherit (cfg) setupOpts;

      cmd = ["Twilight" "TwilightEnable" "TwilightDisable"];
    };
  };
}
