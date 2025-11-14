{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool str listOf;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.latex.vimtex = {
    enable = mkEnableOption ''
      VimTeX is a modern Vim and Neovim filetype and syntax plugin for LaTeX files.

      VimTeX options are under vim.global.vimtex_OPTION
    '';

    setupOpts = mkPluginSetupOption "vimtex" {
      vimtex_view_method = mkOption {
        type = str;
        default = "zathura";
        description = ''
          The pdf viewer to be used

          The default value is "zathura"
        '';
      };

      vimtex_syntax_enabled = mkOption {
        type = bool;
        default = false;
        description = ''
          vimtex syntax enabled

          The default value is false'';
      };

      vimtex_quickfix_ignore_filters = mkOption {
        type = listOf str;
        default = [];
        description = ''
          vimtex quickfix ignore filters

          The default value is []'';
      };
    };
  };
}
