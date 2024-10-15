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
          description = ''
            all of the most important modules that any user would want to have a "just works" experience
          '';

          type = submodule {
            options = {
              enable = mkEnableOption ''
            all of the most important modules that any user would want to have a "just works" experience
            '';
              config = {
                disable = mkOption {
                  description = ''
                    list of modules from to be disabled from core.defaults
                  '';
                  type = listOf str;
                  default = [];
                  example = ["core.autocommands" "core.itero"];
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
