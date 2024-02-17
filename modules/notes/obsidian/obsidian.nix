{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkRenamedOptionModule;
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

      setupOpts = lib.nvim.types.mkPluginSetupOption "Obsidian.nvim" {
        dir = mkOption {
          type = types.str;
          default = "~/my-vault";
          description = "Obsidian vault directory";
        };

        daily_notes = {
          folder = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Directory in which daily notes should be created";
          };
          date_format = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Date format used for creating daily notes";
          };
        };

        completion = {
          nvim_cmp = mkOption {
            # if using nvim-cmp, otherwise set to false
            type = types.bool;
            description = "If using nvim-cmp, otherwise set to false";
            default = config.vim.autocomplete.type == "nvim-cmp";
          };
        };
      };
    };
  };
}
