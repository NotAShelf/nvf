{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.preview.livePreview;
in {
  config.vim.lazy.plugins."live-preview-nvim" = mkIf cfg.enable {
    package = "live-preview-nvim";
    cmd = ["LivePreview"];
    after = ''
      require("livepreview.config").set(${toLuaObject cfg.setupOpts})
    '';
  };
}
