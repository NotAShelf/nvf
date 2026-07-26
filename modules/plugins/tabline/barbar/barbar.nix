{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.tabline.barbar = {
    enable = mkEnableOption "barbar";
    persistedCompat = mkOption {
      type = bool;
      default = config.vim.session.persisted.enable;
      defaultText = literalExpression "config.vim.session.persisted.enable";
      description = "enable compatibility with persisted. automatically `true` when persisted is enabled";
    };

    mappings = {
      closeCurrent = mkMappingOption "Close buffer" "<leader>bd";
      cycleNext = mkMappingOption "Next buffer" "<leader>bn";
      cyclePrevious = mkMappingOption "Previous buffer" "<leader>bp";
      sortByLanguage = mkMappingOption "Sort buffers by extension" "<leader>bse";
      sortByDirectory = mkMappingOption "Sort buffers by directory" "<leader>bsd";
      sortById = mkMappingOption "Sort buffers by ID" "<leader>bsi";
      closeAllButVisible = mkMappingOption "Close all non-visible buffers" "<leader>bo";
    };

    setupOpts = mkPluginSetupOption "barbar-nvim" {
      icons.filetype.enabled = mkOption {
        type = bool;
        default = true;
        example = false;
        description = "Requires 'nvim-web-devicons' or mini-icons substitute if `true`";
      };
      insert_at_end = mkOption {
        type = bool;
        default = false;
        example = true;
        description = ''
          If `true`, new buffers will be inserted at the start / end of the list.
          Default is to insert after current buffer.
        '';
      };
    };
  };
}
