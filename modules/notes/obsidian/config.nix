{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim defaultAttributes;

  cfg = config.vim.notes.obsidian;
  auto = config.vim.autocomplete;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "obsidian-nvim"
      "vim-markdown"
      "tabular"
    ];

    vim.binds.whichKey.register = defaultAttributes {
      "<leader>o" = "+Notes";
    };

    vim.luaConfigRC.obsidian = nvim.dag.entryAnywhere ''
      require("obsidian").setup({
        dir = "${cfg.dir}",
        completion = {
          nvim_cmp = ${
        if (auto.type == "nvim-cmp")
        then "true"
        else "false"
      }
        },
        daily_notes = {
          folder = ${
        if (cfg.daily-notes.folder == "")
        then "nil,"
        else "'${cfg.daily-notes.folder}',"
      }
          date_format = ${
        if (cfg.daily-notes.date-format == "")
        then "nil,"
        else "'${cfg.daily-notes.date-format}',"
      }
        }
      })
    '';
  };
}
