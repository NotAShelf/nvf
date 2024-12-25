{
  lib,
  config,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.runner.run-nvim;
  inherit (options.vim.runner.run-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.run-nvim = {
        package = "run-nvim";
        setupModule = "run";
        inherit (cfg) setupOpts;

        cmd = "Run";

        keys = [
          (mkKeymap "n" cfg.mappings.run "<cmd>Run<cr>" {desc = mappings.run.description;})
          (mkKeymap "n" cfg.mappings.runOverride "<cmd>Run!<cr>" {desc = mappings.runOverride.description;})
          (mkKeymap "n" cfg.mappings.runCommand "<cmd>RunPrompt<cr>" {desc = mappings.run.description;})
        ];
      };

      binds.whichKey.register."<leader>r" = mkDefault "+Run";
    };
  };
}
