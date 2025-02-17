{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.hydra;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [];
      lazy.plugins.hydra = {
        package = "hydra.nvim";
        setupModule = "hydra";
        inherit (cfg) setupOpts;

        event = ["DeferredUIEnter"];
        cmd = ["MCstart" "MCvisual" "MCclear" "MCpattern" "MCvisualPattern" "MCunderCursor"];
      };
    };
  };
}
