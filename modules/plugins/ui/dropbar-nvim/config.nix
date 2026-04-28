{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.ui.dropbar-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.dropbar-nvim = {
      package = "dropbar-nvim";
      setupModule = "dropbar";
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
