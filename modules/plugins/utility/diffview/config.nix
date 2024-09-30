{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.diffview-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"];
      lazy.plugins = [
        {
          package = "diffview-nvim";
          cmd = ["DiffviewClose" "DiffviewFileHistory" "DiffviewFocusFiles" "DiffviewLog" "DiffviewOpen" "DiffviewRefresh" "DiffviewToggleFiles"];
          setupModule = "diffview";
          inherit (cfg) setupOpts;
        }
      ];
    };
  };
}
