{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.notes = {
    obsidian = {
      enable = mkEnableOption "complementary neovim plugins for Obsidian editor";
      dir = mkOption {
        type = types.str;
        default = "~/my-vault";
        description = "Obsidian vault directory";
      };

      daily-notes = {
        folder = mkOption {
          type = types.str;
          default = "";
          description = "Directory in which daily notes should be created";
        };
        date-format = mkOption {
          type = types.str;
          default = "";
          description = "Date format used for creating daily notes";
        };
      };

      completion = {
        nvim_cmp = mkOption {
          # if using nvim-cmp, otherwise set to false
          type = types.bool;
          description = "If using nvim-cmp, otherwise set to false";
        };
      };
    };
  };
}
