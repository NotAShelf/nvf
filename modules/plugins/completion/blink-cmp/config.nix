{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.autocomplete.blink-nvim;
in {
  vim = mkIf cfg.enable {
    lazy.plugins = [
      {
        package = "blink-cmp";
        setupModule = "blink";
        inherit (cfg) setupOpts;
        event = ["InsertEnter" "CmdlineEnter"];
      }
    ];
  };
}
