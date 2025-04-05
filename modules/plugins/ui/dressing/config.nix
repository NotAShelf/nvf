{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.ui.dressing;
in {
  vim = {
    fzf-lua = mkIf (builtins.elem "fzf_lua" cfg.setupOpts.select.backend) {
      enable = true;
    };

    lazy.plugins."dressing-nvim" = mkIf cfg.enable {
      package = "dressing-nvim";
      setupModule = "dressing";
      inherit (cfg) setupOpts;
    };
  };
}
