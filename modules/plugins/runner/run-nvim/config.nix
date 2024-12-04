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
          (mkKeymap "n" cfg.mappings.run "<cmd>Run<CR>" {desc = mappings.run.description;})
          (mkKeymap "n" cfg.mappings.runOverride "<cmd>Run!<CR>" {desc = mappings.runOverride.description;})
          (mkKeymap "n" cfg.mappings.runCommand ''
              function()
                local input = vim.fn.input("Run command: ")
                if input ~= "" then require("run").run(input, false) end
              end
            '' {
              desc = mappings.run.description;
              lua = true;
            })
        ];
      };

      binds.whichKey.register."<leader>r" = mkDefault "+Run";
    };
  };
}
