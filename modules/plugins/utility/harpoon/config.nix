{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) pushDownDefault mkKeymap;

  cfg = config.vim.navigation.harpoon;

  keys = cfg.mappings;
  inherit (options.vim.navigation.harpoon) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"];

      lazy.plugins.harpoon = {
        package = "harpoon";
        setupModule = "harpoon";
        inherit (cfg) setupOpts;

        cmd = ["Harpoon"];

        keys = [
          (mkKeymap "n" keys.markFile "<Cmd>lua require('harpoon'):list():add()<CR>" {desc = mappings.markFile.description;})
          (mkKeymap "n" keys.listMarks "<Cmd>lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<CR>" {desc = mappings.listMarks.description;})
          (mkKeymap "n" keys.file1 "<Cmd>lua require('harpoon'):list():select(1)<CR>" {desc = mappings.file1.description;})
          (mkKeymap "n" keys.file2 "<Cmd>lua require('harpoon'):list():select(2)<CR>" {desc = mappings.file2.description;})
          (mkKeymap "n" keys.file3 "<Cmd>lua require('harpoon'):list():select(3)<CR>" {desc = mappings.file3.description;})
          (mkKeymap "n" keys.file4 "<Cmd>lua require('harpoon'):list():select(4)<CR>" {desc = mappings.file4.description;})
        ];
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>a" = "Harpoon Mark";
      };
    };
  };
}
