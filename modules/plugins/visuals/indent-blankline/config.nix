{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.indent-blankline;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.indent-blankline-nvim = {
      package = "indent-blankline-nvim";
      setupModule = "ibl";
      inherit (cfg) setupOpts;
      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
      cmd = ["IBLEnable" "IBLDisable" "IBLToggle" "IBLEnableScope" "IBLDisableScope" "IBLToggleScope"];
    };
  };
}
