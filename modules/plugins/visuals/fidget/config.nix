{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.fidget-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy = {
      plugins = [
        {
          package = "fidget-nvim";
          setupModule = "fidget";
          event = "LspAttach";
          inherit (cfg) setupOpts;
        }
      ];
    };
  };
}
