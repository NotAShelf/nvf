{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.guess-indent-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.guess-indent-nvim = {
      package = "guess-indent-nvim";
      setupModule = "guess-indent";
      inherit (cfg) setupOpts;

      event = ["BufReadPre" "BufNewFile"];
      cmd = ["GuessIndent"];
    };
  };
}
