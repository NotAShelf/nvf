{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.satellite-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.satellite-nvim = {
      package = "satellite-nvim";
      setupModule = "satellite";
      inherit (cfg) setupOpts;

      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
    };
  };
}
