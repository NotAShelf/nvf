{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool str nullOr;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption;

  autocompleteCfg = config.vim.autocomplete;
in {
  imports = let
    renamedSetupOption = oldPath: newPath:
      mkRenamedOptionModule
      (["vim" "notes" "obsidian"] ++ oldPath)
      (["vim" "notes" "obsidian" "setupOpts"] ++ newPath);
  in [
    (renamedSetupOption ["dir"] ["dir"])
    (renamedSetupOption ["daily-notes" "folder"] ["daily_notes" "folder"])
    (renamedSetupOption ["daily-notes" "date-format"] ["daily_notes" "date_format"])
    (renamedSetupOption ["completion"] ["completion"])
  ];
  options.vim.notes = {
    obsidian = {
      enable = mkEnableOption "complementary neovim plugins for Obsidian editor";

      setupOpts = mkPluginSetupOption "Obsidian.nvim" {
        daily_notes = {
          folder = mkOption {
            type = nullOr str;
            default = null;
            description = "Directory in which daily notes should be created";
          };
          date_format = mkOption {
            type = nullOr str;
            default = null;
            description = "Date format used for creating daily notes";
          };
        };

        completion = {
          nvim_cmp = mkOption {
            # If using nvim-cmp, otherwise set to false
            type = bool;
            description = "If using nvim-cmp, otherwise set to false";
            default = autocompleteCfg.nvim-cmp.enable || autocompleteCfg.blink-cmp.enable;
          };
        };
      };
    };
  };
}
