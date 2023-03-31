{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.notes = {
    obsidian = {
      enable = mkEnableOption "Complementary neovim plugins for Obsidian editor";
      dir = mkOption {
        type = types.str;
        default = "~/my-vault";
        description = "Obsidian vault directory";
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
