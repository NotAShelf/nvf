{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.statusline.feline-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.feline-nvim = {
        event = "UIEnter";

        package = "feline-nvim";
        setupModule = "feline";
        inherit (cfg) setupOpts;
      };
    };
  };
}
