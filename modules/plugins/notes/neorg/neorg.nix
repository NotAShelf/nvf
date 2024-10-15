{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) submodule listOf str;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
in {
  options.vim.notes.neorg = {
    enable = mkEnableOption ''
      Neorg: An intuitive note-taking and organization tool with a structured nested syntax.
    '';

    setupOpts = mkPluginSetupOption "Neorg" {
      load = {
        "core.defaults" = mkOption {
          default = {};

          type = submodule {
            options = {
              enable = mkEnableOption "wrapper to interface with several different completion engines.";
              config = {
                disable = mkOption {
                  type = listOf str;
                  default = [];
                };
              };
            };
          };
        };
      };
    };

    treesitter = {
      enable = mkEnableOption "Neorg treesitter" // {default = config.vim.languages.enableTreesitter;};
      norgPackage = mkGrammarOption pkgs "norg";
    };
  };
}
