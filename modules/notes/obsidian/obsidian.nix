{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str bool;
in {
  options.vim.notes = {
    obsidian = {
      enable = mkEnableOption "complementary neovim plugins for Obsidian editor";
      dir = mkOption {
        type = str;
        default = "~/my-vault";
        description = "Obsidian vault directory";
      };

      daily-notes = {
        folder = mkOption {
          type = str;
          default = "";
          description = "Directory in which daily notes should be created";
        };
        date-format = mkOption {
          type = str;
          default = "";
          description = "Date format used for creating daily notes";
        };
      };

      completion = {
        nvim_cmp = mkOption {
          type = bool;
          description = "If using nvim-cmp, otherwise set to false";
        };
      };
    };
  };
}
