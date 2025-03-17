{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf str bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.trim-nvim = {
    enable = mkEnableOption ''
      automatic removal of trailing whitespaces and lines [trim-nvim]
    '';

    setupOpts = mkPluginSetupOption "trim-nvim" {
      ft_blocklist = mkOption {
        type = listOf str;
        default = ["markdown"];
        description = "List of filetypes to not trim";
      };
      highlight = mkOption {
        type = bool;
        default = false;
        description = "Enable highlighting trailing spaces";
      };
    };
  };
}
