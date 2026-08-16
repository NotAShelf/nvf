{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.images.img-clip;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.img-clip = {
      package = "img-clip";
      setupModule = "img-clip";
      inherit (cfg) setupOpts;
      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
      cmd = ["PasteImage" "ImgClipDebug" "ImgClipConfig"];
    };
  };
}
