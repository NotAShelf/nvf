{
  lib,
  config,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLznBinding mkSetLuaLznBinding;

  cfg = config.vim.runner.run-nvim;
  mappingDefinitions = options.vim.runner.run-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.run-nvim = {
        package = "run-nvim";
        setupModule = "run";
        inherit (cfg) setupOpts;

        cmd = "Run";

        keys = [
          (mkSetLznBinding "n" mappings.run "<cmd>Run<CR>")
          (mkSetLznBinding "n" mappings.runOverride "<cmd>Run!<CR>")
          (mkSetLuaLznBinding "n" mappings.runCommand ''
            function()
              local input = vim.fn.input("Run command: ")
              if input ~= "" then require("run").run(input, false) end
            end
          '')
        ];
      };

      binds.whichKey.register."<leader>r" = mkDefault "+Run";
    };
  };
}
