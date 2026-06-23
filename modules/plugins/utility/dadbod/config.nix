{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.dadbod;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.vim-dadbod = {
      package = "vim-dadbod";
      cmd = ["DB"];
    };
  };
}
