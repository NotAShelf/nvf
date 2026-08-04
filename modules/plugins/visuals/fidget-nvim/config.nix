{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.fidget-nvim;
  catppuccinIntegrationEnabled =
    config.vim.theme.default
    == "catppuccin"
    && config.vim.theme.catppuccin.integrations.fidget.enable;
  notificationOpts = cfg.setupOpts.notification or {};
  windowOpts = notificationOpts.window or {};
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.fidget-nvim = {
      package = "fidget-nvim";
      setupModule = "fidget";
      event = "LspAttach";
      setupOpts =
        cfg.setupOpts
        // lib.optionalAttrs catppuccinIntegrationEnabled {
          notification =
            notificationOpts
            // {
              window = windowOpts // lib.optionalAttrs (!(windowOpts ? winblend)) {winblend = 0;};
            };
        };
    };
  };
}
