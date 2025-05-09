{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.surround;
  mkLznKey = mode: key: {
    inherit mode key;
  };
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.nvim-surround = {
        package = "nvim-surround";
        setupModule = "nvim-surround";
        inherit (cfg) setupOpts;

        event = ["BufReadPre" "BufNewFile"];

        keys = [
          (mkLznKey "i" cfg.setupOpts.keymaps.insert)
          (mkLznKey "i" cfg.setupOpts.keymaps.insert_line)
          (mkLznKey "x" cfg.setupOpts.keymaps.visual)
          (mkLznKey "x" cfg.setupOpts.keymaps.visual_line)
          (mkLznKey "n" cfg.setupOpts.keymaps.normal)
          (mkLznKey "n" cfg.setupOpts.keymaps.normal_cur)
          (mkLznKey "n" cfg.setupOpts.keymaps.normal_line)
          (mkLznKey "n" cfg.setupOpts.keymaps.normal_cur_line)
          (mkLznKey "n" cfg.setupOpts.keymaps.delete)
          (mkLznKey "n" cfg.setupOpts.keymaps.change)
          (mkLznKey "n" cfg.setupOpts.keymaps.change_line)
        ];
      };
    };
  };
}
