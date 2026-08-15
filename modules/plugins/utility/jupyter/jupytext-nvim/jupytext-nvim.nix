{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.jupytext-nvim = {
    enable = mkEnableOption "jupytext-nvim to automatically convert .ipynb files in Neovim";

    setupOpts = mkPluginSetupOption "jupytext-nvim" {
      style = lib.mkOption {
        type = lib.types.str;
        default = "percent";
        description = "Default format to convert notebooks into (e.g., 'markdown', 'light', 'percent').";
      };
      output_extension = lib.mkOption {
        type = lib.types.str;
        default = "py";
        description = "Extension of the output file (e.g., 'auto', 'md', 'py').";
      };
      force_ft = lib.mkOption {
        type = lib.types.str;
        default = "python";
        description = "Force the filetype of the converted document.";
      };
    };
  };
}
