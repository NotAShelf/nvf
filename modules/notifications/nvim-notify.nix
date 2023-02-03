{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notify.nvim-notify;
in {
  options.vim.notify.nvim-notify = {
    enable = mkOption {
      type = types.bool;
      description = "Enable animated notifications";
    };
  };

  config =
    mkIf cfg.enable
    {
      vim.startPlugins = ["nvim-notify"];
    };
}
