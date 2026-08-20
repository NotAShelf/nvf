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
      runAdvance = mkMappingOption "Run the current cell and advance to the next one" "<S-CR>";
      runStay = mkMappingOption "Run the current cell and stay on it" "<C-CR>";
      runAdvanceAlt = mkMappingOption "Run the current cell and advance (alternative binding)" "<leader>nr";
      runAll = mkMappingOption "Run all cells" "<leader>nR";
      runAbove = mkMappingOption "Run all cells above the cursor" "<leader>nA";
      runBelow = mkMappingOption "Run all cells below the cursor" "<leader>nB";
      addAbove = mkMappingOption "Add a cell above the cursor" "<leader>na";
      addBelow = mkMappingOption "Add a cell below the cursor" "<leader>nb";
      deleteCell = mkMappingOption "Delete the current cell" ("<leader>n" + "d");
      moveUp = mkMappingOption "Move the current cell up" "<leader>nk";
      moveDown = mkMappingOption "Move the current cell down" "<leader>nj";
      toMarkdown = mkMappingOption "Convert the current cell to markdown" "<leader>nm";
      toCode = mkMappingOption "Convert the current cell to code" "<leader>ny";
      pickKernel = mkMappingOption "Pick a kernel for the notebook" "<leader>nK";
      startKernel = mkMappingOption "Start the notebook kernel" "<leader>ns";
      stopKernel = mkMappingOption "Stop the notebook kernel" "<leader>nS";
      interruptKernel = mkMappingOption "Interrupt the kernel" "<leader>ni";
      restartKernel = mkMappingOption "Restart the kernel" "<leader>nx";
      clearOutput = mkMappingOption "Clear the current cell's output" "<leader>nc";
      clearAll = mkMappingOption "Clear all cell outputs" "<leader>nC";
      nextCell = mkMappingOption "Jump to the next cell" "]c";
      prevCell = mkMappingOption "Jump to the previous cell" "[c";
      nextImage = mkMappingOption "Jump to the next image cell" "]i";
      prevImage = mkMappingOption "Jump to the previous image cell" "[i";
      enterOutputDn = mkMappingOption "Enter the output below the cursor" "<C-j>";
      enterOutputUp = mkMappingOption "Enter the output above the cursor" "<C-k>";
      saveImage = mkMappingOption "Save the cell image" "<leader>nI";
      deleteImage = mkMappingOption "Delete the cell image" "<leader>nD";
      refresh = mkMappingOption "Refresh the notebook display" "<leader>nL";
      openLink = mkMappingOption "Open the link under the cursor" "gx";
    };
  };
}
