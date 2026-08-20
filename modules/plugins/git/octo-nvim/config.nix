{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.nvim.binds) pushDownDefault mkKeymap;

  cfg = config.vim.git.octo-nvim;

  keys = cfg.mappings;
  inherit (options.vim.git.octo-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"];
      visuals.nvim-web-devicons.enable = mkDefault true;

      lazy.plugins.octo-nvim = {
        package = "octo-nvim";
        setupModule = "octo";
        inherit (cfg) setupOpts;

        cmd = ["Octo"];

        keys = [
          (mkKeymap "n" keys.issueList ":Octo issue list<cr>" {desc = mappings.issueList.description;})
          (mkKeymap "n" keys.prList ":Octo pr list<cr>" {desc = mappings.prList.description;})
          (mkKeymap "n" keys.discussionList ":Octo discussion list<cr>" {desc = mappings.discussionList.description;})
          (mkKeymap "n" keys.notificationList ":Octo notification list<cr>" {desc = mappings.notificationList.description;})
          (mkKeymap "n" keys.search ''function() require("octo.utils").create_base_search_command { include_current_repo = true } end '' {
            desc = mappings.search.description;
            lua = true;
          })
        ];
      };

      binds.whichKey.register = mkIf config.vim.vendoredKeymaps.enable (pushDownDefault {
        "<leader>o" = "+Octo";
      });
    };
  };
}
