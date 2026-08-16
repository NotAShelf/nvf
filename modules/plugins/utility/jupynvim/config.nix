{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.jupynvim;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.jupynvim = {
        package = "jupynvim";
        setupModule = "jupynvim";
        event = [
          {
            event = "BufReadCmd";
            pattern = "*.ipynb";
          }
          {
            event = "BufNewFile";
            pattern = "*.ipynb";
          }
        ];
        setupOpts =
          lib.recursiveUpdate
          {
            keymaps = {
              run_advance = cfg.mappings.run_advance;
              run_stay = cfg.mappings.run_stay;
              run_advance_alt = cfg.mappings.run_advance_alt;
              run_all = cfg.mappings.run_all;
              run_above = cfg.mappings.run_above;
              run_below = cfg.mappings.run_below;
              add_above = cfg.mappings.add_above;
              add_below = cfg.mappings.add_below;
              delete_cell = cfg.mappings.delete_cell;
              move_up = cfg.mappings.move_up;
              move_down = cfg.mappings.move_down;
              to_markdown = cfg.mappings.to_markdown;
              to_code = cfg.mappings.to_code;
              pick_kernel = cfg.mappings.pick_kernel;
              start_kernel = cfg.mappings.start_kernel;
              stop_kernel = cfg.mappings.stop_kernel;
              interrupt_kernel = cfg.mappings.interrupt_kernel;
              restart_kernel = cfg.mappings.restart_kernel;
              clear_output = cfg.mappings.clear_output;
              clear_all = cfg.mappings.clear_all;
              next_cell = cfg.mappings.next_cell;
              prev_cell = cfg.mappings.prev_cell;
              next_image = cfg.mappings.next_image;
              prev_image = cfg.mappings.prev_image;
              enter_output_dn = cfg.mappings.enter_output_dn;
              enter_output_up = cfg.mappings.enter_output_up;
              save_image = cfg.mappings.save_image;
              delete_image = cfg.mappings.delete_image;
              refresh = cfg.mappings.refresh;
              open_link = cfg.mappings.open_link;
            };
          }
          cfg.setupOpts;
      };

      extraPackages = [
        pkgs.imagemagick
        pkgs.chafa
      ];
    };
  };
}
