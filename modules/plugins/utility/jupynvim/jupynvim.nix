{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) nullOr str bool enum ints listOf;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.jupynvim = {
    enable = mkEnableOption ''
      jupynvim, a Jupyter notebook interface for Neovim with a native Rust backend.
      See <https://github.com/sheng-tse/jupynvim#configuration> for all configuration options.
    '';

    setupOpts = mkPluginSetupOption "jupynvim" {
      log_level = mkOption {
        type = enum ["trace" "debug" "info" "warn" "error"];
        default = "info";
        description = "Verbosity for both the Rust backend and the Lua frontend.";
      };

      image_renderer = mkOption {
        type = enum ["placeholder" "kitty" "chafa"];
        default = "placeholder";
        description = ''
          How code-cell outputs and embedded markdown images are rendered.

          * `placeholder` - uses the Kitty Unicode placeholder protocol. The image is
            anchored to buffer text and stays put when scrolling. Required for animated
            GIFs.
          * `kitty` - uses direct kitty placement. Lives at fixed screen coordinates and
            does not follow scroll.
          * `chafa` - an ASCII-art fallback for terminals without graphics support.
        '';
      };

      image_rows = mkOption {
        type = ints.u16;
        default = 16;
        description = "Inline image grid size in terminal cells (rows).";
      };

      image_cols = mkOption {
        type = ints.u16;
        default = 48;
        description = "Inline image grid size in terminal cells (cols).";
      };

      core_path = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          Override the path to the `jupynvim-core` binary. Auto-detected from the
          plugin directory if unset.
        '';
      };

      disable_default_keymaps = mkOption {
        type = bool;
        default = false;
        description = "Skip the entire default keymap set if you want to bind everything yourself.";
      };

      auto_venv = mkOption {
        type = bool;
        default = true;
        description = ''
          Walk up from the notebook's directory to find a `.venv` and use its interpreter
          as the kernel when `ipykernel` is installed there.
        '';
      };

      lsp_blocklist = mkOption {
        type = listOf str;
        default = [];
        description = ''
          LSP servers to skip on jupynvim buffers. Useful for servers that misbehave on
          `.ipynb` URIs without advertising notebook capability.
        '';
      };

      smooth_scroll = mkOption {
        type = bool;
        default = false;
        description = "Restore animated (smooth) scrolling inside notebook buffers.";
      };
    };

    mappings = {
      run_advance = mkMappingOption "Run the current cell and advance to the next one" "<S-CR>";
      run_stay = mkMappingOption "Run the current cell and stay on it" "<C-CR>";
      run_advance_alt = mkMappingOption "Run the current cell and advance (alternative binding)" "<leader>nr";
      run_all = mkMappingOption "Run all cells" "<leader>nR";
      run_above = mkMappingOption "Run all cells above the cursor" "<leader>nA";
      run_below = mkMappingOption "Run all cells below the cursor" "<leader>nB";
      add_above = mkMappingOption "Add a cell above the cursor" "<leader>na";
      add_below = mkMappingOption "Add a cell below the cursor" "<leader>nb";
      delete_cell = mkMappingOption "Delete the current cell" "<leader>nd";
      move_up = mkMappingOption "Move the current cell up" "<leader>nk";
      move_down = mkMappingOption "Move the current cell down" "<leader>nj";
      to_markdown = mkMappingOption "Convert the current cell to markdown" "<leader>nm";
      to_code = mkMappingOption "Convert the current cell to code" "<leader>ny";
      pick_kernel = mkMappingOption "Pick a kernel for the notebook" "<leader>nK";
      start_kernel = mkMappingOption "Start the notebook kernel" "<leader>ns";
      stop_kernel = mkMappingOption "Stop the notebook kernel" "<leader>nS";
      interrupt_kernel = mkMappingOption "Interrupt the kernel" "<leader>ni";
      restart_kernel = mkMappingOption "Restart the kernel" "<leader>nx";
      clear_output = mkMappingOption "Clear the current cell's output" "<leader>nc";
      clear_all = mkMappingOption "Clear all cell outputs" "<leader>nC";
      next_cell = mkMappingOption "Jump to the next cell" "]c";
      prev_cell = mkMappingOption "Jump to the previous cell" "[c";
      next_image = mkMappingOption "Jump to the next image cell" "]i";
      prev_image = mkMappingOption "Jump to the previous image cell" "[i";
      enter_output_dn = mkMappingOption "Enter the output below the cursor" "<C-j>";
      enter_output_up = mkMappingOption "Enter the output above the cursor" "<C-k>";
      save_image = mkMappingOption "Save the cell image" "<leader>nI";
      delete_image = mkMappingOption "Delete the cell image" "<leader>nD";
      refresh = mkMappingOption "Refresh the notebook display" "<leader>nL";
      open_link = mkMappingOption "Open the link under the cursor" "gx";
    };
  };
}
