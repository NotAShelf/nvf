{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) lines;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
in {
  options.vim.notes.neorg = {
    enable = mkEnableOption "neorg: Neovim plugin for Neorg";

    setupOpts = mkOption {
      type = lines;
      default = ''

        load = {
          ['core.defaults'] = {}, -- Loads default behaviour
          ['core.concealer'] = {}, -- Adds pretty icons to your documents
          ['core.export'] = {}, -- Adds export options
          ['core.integrations.telescope'] = {}, -- Telescope integration
          ['core.dirman'] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = '~/Documents/neorg',
              },
            },
          },
        },
      '';
      description = "Neorg configuration";
    };

    treesitter = {
      enable = mkEnableOption "Neorg treesitter" // {default = config.vim.languages.enableTreesitter;};
      norgPackage = mkGrammarOption pkgs "norg";
    };
  };
}
