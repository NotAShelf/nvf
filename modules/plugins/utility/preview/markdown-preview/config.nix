{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.preview.markdownPreview;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [pkgs.vimPlugins.markdown-preview-nvim];

    vim.globals = {
      mkdp_auto_start = cfg.autoStart;
      mkdp_auto_close = cfg.autoClose;
      mkdp_refresh_slow = cfg.lazyRefresh;
      mkdp_filetypes = cfg.filetypes;
      mkdp_command_for_global = cfg.alwaysAllowPreview;
      mkdp_open_to_the_world = cfg.broadcastServer;
      mkdp_open_ip = cfg.customIP;
      mkdp_port = cfg.customPort;
    };
  };
}
