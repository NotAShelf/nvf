{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notes.obsidian;
  auto = config.vim.autocomplete;
in {
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

  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "obsidian-nvim"
      "vim-markdown"
      "tabular"
    ];

    vim.luaConfigRC.obsidian = nvim.dag.entryAnywhere ''
      require("obsidian").setup({
        dir = "${cfg.dir}",
        completion = {
          nvim_cmp = ${
        if (auto.type == "nvim-cmp")
        then "true"
        else "false"
      }
        }
      })
    '';
  };
}
