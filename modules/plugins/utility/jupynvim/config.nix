{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) recursiveUpdate;
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
          recursiveUpdate
          {
            keymaps = {
              run_advance = cfg.mappings.runAdvance;
              run_stay = cfg.mappings.runStay;
              run_advance_alt = cfg.mappings.runAdvanceAlt;
              run_all = cfg.mappings.runAll;
              run_above = cfg.mappings.runAbove;
              run_below = cfg.mappings.runBelow;
              add_above = cfg.mappings.addAbove;
              add_below = cfg.mappings.addBelow;
              delete_cell = cfg.mappings.deleteCell;
              move_up = cfg.mappings.moveUp;
              move_down = cfg.mappings.moveDown;
              to_markdown = cfg.mappings.toMarkdown;
              to_code = cfg.mappings.toCode;
              pick_kernel = cfg.mappings.pickKernel;
              start_kernel = cfg.mappings.startKernel;
              stop_kernel = cfg.mappings.stopKernel;
              interrupt_kernel = cfg.mappings.interruptKernel;
              restart_kernel = cfg.mappings.restartKernel;
              clear_output = cfg.mappings.clearOutput;
              clear_all = cfg.mappings.clearAll;
              next_cell = cfg.mappings.nextCell;
              prev_cell = cfg.mappings.prevCell;
              next_image = cfg.mappings.nextImage;
              prev_image = cfg.mappings.prevImage;
              enter_output_dn = cfg.mappings.enterOutputDn;
              enter_output_up = cfg.mappings.enterOutputUp;
              save_image = cfg.mappings.saveImage;
              delete_image = cfg.mappings.deleteImage;
              refresh = cfg.mappings.refresh;
              open_link = cfg.mappings.openLink;
            };
          }
          cfg.setupOpts;
      };
    };
  };
}
