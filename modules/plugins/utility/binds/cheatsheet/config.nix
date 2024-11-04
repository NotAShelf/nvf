{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;

  cfg = config.vim.binds.cheatsheet;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.cheatsheet-nvim = {
      package = "cheatsheet-nvim";
      setupModule = "cheatsheet";
      setupOpts = {};
      cmd = ["Cheatsheet" "CheatsheetEdit"];

      before = optionalString config.vim.lazy.enable "require('lz.n').trigger_load('telescope')";
    };
  };
}
