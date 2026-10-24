{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.git.atlas-nvim = {
    enable = mkEnableOption "review pull requests and manage issues from Neovim [atlas.nvim]";
    setupOpts = mkPluginSetupOption "atlas.nvim" {
      ui.picker = mkOption {
        type = enum ["default" "snacks" "fzf-lua"];
        default =
          if config.vim.utility.snacks-nvim.enable && (config.vim.utility.snacks-nvim.setupOpts.picker.enabled or false)
          then "snacks"
          else if config.vim.fzf-lua.enable
          then "fzf-lua"
          else "default";
        defaultText = literalExpression ''
          if config.vim.utility.snacks-nvim.enable
            && (config.vim.utility.snacks-nvim.setupOpts.picker.enabled or false)
          then "snacks"
          else if config.vim.fzf-lua.enable
          then "fzf-lua"
          else "default"
        '';
        description = ''
          Picker backend used by Atlas. Defaults to an enabled Snacks picker,
          then fzf-lua, otherwise Atlas's built-in picker. Explicit selection
          avoids optional dependency detection through the lazy-require handler.
        '';
      };
    };

    mappings = {
      open = mkMappingOption "Open actions [Atlas]" "<leader>ga";
      review = mkMappingOption "Review pull request [Atlas]" "<leader>gr";
      browse = mkMappingOption "Browse repository [Atlas]" "<leader>go";
      diff = mkMappingOption "Enter Git range to diff [Atlas]" "<leader>gd";
      notes = mkMappingOption "Local review notes [Atlas]" "<leader>gN";
      search = mkMappingOption "Search providers [Atlas]" "<leader>g/";
    };
  };
}
