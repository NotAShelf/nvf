{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.formatter.conform-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.conform-nvim = {
      package = "conform-nvim";
      setupModule = "conform";
      inherit (cfg) setupOpts;
      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
      cmd = ["ConformInfo"];
    };
  };
}
