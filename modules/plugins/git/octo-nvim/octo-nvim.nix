{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;

  selectedPicker =
    if
      config.vim.utility.snacks-nvim.enable
      && (config.vim.utility.snacks-nvim.setupOpts.picker.enabled or false)
    then "snacks"
    else if config.vim.telescope.enable
    then "telescope"
    else if config.vim.fzf-lua.enable
    then "fzf-lua"
    else "default";
in {
  options.vim.git.octo-nvim = {
    enable = mkEnableOption "Edit and review GitHub issues, pull requests, and discussions from the comfort of your favorite editor. [octo-nvim]";
    setupOpts = mkPluginSetupOption "octo-nvim" {
      picker = mkOption {
        type = enum ["telescope" "fzf-lua" "snacks" "default"];
        default = selectedPicker;
        defaultText = literalExpression ''
          if config.vim.utility.snacks-nvim.enable
            && (config.vim.utility.snacks-nvim.setupOpts.picker.enabled or false)
          then "snacks"
          else if config.vim.telescope.enable
          then "telescope"
          else if config.vim.fzf-lua.enable
          then "fzf-lua"
          else "default"
        '';
        description = ''
          Picker backend used by octo.nvim

          Defaults to an enabled picker module, preferring Snacks, then Telescope,
          then fzf-lua. Falls back to Neovim's built-in `vim.ui.select`.
        '';
      };
    };
    mappings = {
      issueList = mkMappingOption "List GitHub Issues" "<leader>oi";
      prList = mkMappingOption "List GitHub Pull Requests" "<leader>op";
      discussionList = mkMappingOption "List GitHub Discussions" "<leader>od";
      notificationList = mkMappingOption "List GitHub Notifications" "<leader>ol";
      search = mkMappingOption "Search GitHub" "<leader>os";
    };
  };
}
