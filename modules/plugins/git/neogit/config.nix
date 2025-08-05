{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) pushDownDefault mkKeymap;

  cfg = config.vim.git.neogit;

  keys = cfg.mappings;
  inherit (options.vim.git.neogit) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"];

      lazy.plugins.neogit = {
        package = "neogit";
        setupModule = "neogit";
        inherit (cfg) setupOpts;

        cmd = ["Neogit"];

        keys = [
          (mkKeymap "n" keys.open "<Cmd>Neogit<CR>" {desc = mappings.open.description;})
          (mkKeymap "n" keys.commit "<Cmd>Neogit commit<CR>" {desc = mappings.commit.description;})
          (mkKeymap "n" keys.pull "<Cmd>Neogit pull<CR>" {desc = mappings.pull.description;})
          (mkKeymap "n" keys.push "<Cmd>Neogit push<CR>" {desc = mappings.push.description;})
        ];
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>g" = "+Git";
      };
    };
  };
}
