{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str enum nullOr listOf;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.jupyter.magma-nvim = {
    enable = mkEnableOption "magma-nvim Jupyter integration for Neovim";
    python3Packages = mkOption {
      type = listOf str;
      default = [];
      description = ''
        Additional Python package attribute names to make available to the
        built-in `python3` Jupyter kernel shipped with this module.

        The minimal set magma-nvim itself needs to run is always included: the
        `pynvim` rplugin host, `jupyter-client` to drive kernels, and
        `ipykernel` for the fallback `python3` kernel. Only add packages here if
        you want extra libraries in that fallback kernel.

        This is **not** the place to collect the libraries your notebooks
        `import`. magma-nvim launches kernels as external processes, and each
        kernel runs in its own environment: a venv, uv-managed environment,
        nix shell or the system Python that you have registered as a Jupyter
        kernelspec. Those kernels are discovered automatically, so project
        dependencies should live in the environment they belong to, not in the
        Neovim host.
      '';
    };
    setupOpts = mkPluginSetupOption "magma-nvim" {
      automaticallyOpenOutput = mkOption {
        type = bool;
        default = true;
        description = "Automatically open floating output window after cell execution.";
      };
      defaultKernel = mkOption {
        type = str;
        default = "python3";
        description = ''
          Name of the Jupyter kernelspec that `<leader>mn` (or the configured
          init mapping) launches by default. Any kernelspec Jupyter can find is
          valid — including ones registered from a project venv, a uv-managed
          environment, a nix shell, or the system Python. Use the
          `<leader>mk` mapping or `:MagmaInit` with no arguments to pick a
          different kernel interactively.
        '';
      };
      preferNixVenvWrapper = mkOption {
        type = bool;
        default = false;
        description = ''
          When registering a venv kernel (`<leader>mK`), prefer the venv's
          `bin/python3-nix` wrapper script over the bare interpreter if it
          exists. Some nix + uv devShells ship such a wrapper to inject the
          nix shared libraries (libstdc++, zlib, glib) that pip-built wheels
          like `pyzmq` need at runtime. Off by default so the framework does
          not assume any particular venv convention; enable it if your
          devShell provides such a wrapper.
        '';
      };
      imageProvider = mkOption {
        type = enum ["none" "ueberzug" "kitty"];
        default = "none";
        description = "Backend provider for rendering images and plots.";
      };
      wrapOutput = mkOption {
        type = bool;
        default = true;
        description = "Wrap text inside floating output windows.";
      };
      outputWindowBorders = mkOption {
        type = bool;
        default = true;
        description = "Display borders around floating output windows.";
      };
      cellHighlightGroup = mkOption {
        type = str;
        default = "CursorLine";
        description = "Highlight group applied to active cell lines.";
      };
      savePath = mkOption {
        type = nullOr str;
        default = null;
        description = "Directory path where magma-nvim saves state JSON files.";
      };
      copyOutput = mkOption {
        type = bool;
        default = false;
        description = "Automatically copy evaluated cell outputs to system clipboard.";
      };
      showMimetypeDebug = mkOption {
        type = bool;
        default = false;
        description = "Display raw MIME-type debug headers in floating output windows.";
      };
    };
    mappings = {
      init = mkMappingOption "Initialize a Jupyter kernel for the current buffer" "<leader>mn";
      deinit = mkMappingOption "Deinitialize the current buffer's kernel" "<leader>mq";
      evaluateLine = mkMappingOption "Evaluate current line" "<leader>ml";
      evaluateOperator = mkMappingOption "Evaluate text object or selection operator" "<leader>mO";
      evaluateVisual = mkMappingOption "Evaluate visual selection" "<leader>mv";
      reevaluateCell = mkMappingOption "Re-evaluate current cell" "<leader>mC";
      delete = mkMappingOption "Delete current cell output" "<leader>md";
      deleteAll = mkMappingOption "Delete all cell outputs" "<leader>mD";
      showOutput = mkMappingOption "Show output window for current cell" "<leader>ms";
      restart = mkMappingOption "Restart current Jupyter kernel" "<leader>mr";
      interrupt = mkMappingOption "Interrupt current kernel execution" "<leader>mi";
      save = mkMappingOption "Save cells and outputs to a JSON file" "<leader>mw";
      load = mkMappingOption "Load cells and outputs from a JSON file" "<leader>mL";
      enterOutput = mkMappingOption "Enter the output window" "<leader>me";
      runAll = mkMappingOption "Evaluate the entire buffer" "<leader>ma";
      runCell = mkMappingOption "Evaluate the jupytext cell under the cursor" "<leader>mR";
      insertCodeCellAbove = mkMappingOption "Insert a code cell above the cursor" "<leader>mB";
      insertCodeCellBelow = mkMappingOption "Insert a code cell below the cursor" "<leader>mb";
      insertMarkdownCellAbove = mkMappingOption "Insert a markdown cell above the cursor" "<leader>mT";
      insertMarkdownCellBelow = mkMappingOption "Insert a markdown cell below the cursor" "<leader>mt";
      selectKernel = mkMappingOption "Select a Jupyter kernel interactively" "<leader>mk";
      registerKernel = mkMappingOption "Register the current Python environment as a kernel" "<leader>mK";
    };
  };
}
