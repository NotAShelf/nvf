{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.blink-indent;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.blink-indent = {
      package = "blink-indent";
      setupModule = "blink.indent";
      inherit (cfg) setupOpts;

      event = ["BufEnter"];
    };
  };
}
