{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.auto-indent-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.auto-indent-nvim = {
      package = "auto-indent-nvim";
      setupModule = "auto-indent";
      inherit (cfg) setupOpts;

      event = ["BufReadPre"];
      cmd = ["AutoIndentGetIndents"];
    };
  };
}
