{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.icon-picker;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["dressing-nvim"];

    vim.lazy.plugins = [
      {
        package = "icon-picker-nvim";
        setupModule = "icon-picker";
        setupOpts = {
          disable_legacy_commands = true;
        };

        cmd = ["IconPickerInsert" "IconPickerNormal" "IconPickerYank"];
      }
    ];
  };
}
