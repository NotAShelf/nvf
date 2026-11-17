{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) pushDownDefault mkKeymap;

  cfg = config.vim.git.atlas-nvim;
  keys = cfg.mappings;
  inherit (options.vim.git.atlas-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      extraPackages = [
        pkgs.curl
        pkgs.git
        pkgs.gh
      ];

      lazy.plugins.atlas-nvim = {
        package = "atlas-nvim";
        setupModule = "atlas";
        inherit (cfg) setupOpts;
        cmd = ["Atlas"];
        keys = [
          (mkKeymap "n" keys.open "<cmd>Atlas<cr>" {desc = mappings.open.description;})
          (mkKeymap "n" keys.review "<cmd>Atlas review<cr>" {desc = mappings.review.description;})
          (mkKeymap "n" keys.browse "<cmd>Atlas browse .<cr>" {desc = mappings.browse.description;})
          (mkKeymap "n" keys.diff ":Atlas diff " {desc = mappings.diff.description;})
          (mkKeymap "n" keys.notes "<cmd>Atlas notes<cr>" {desc = mappings.notes.description;})
          (mkKeymap "n" keys.search "<cmd>Atlas search<cr>" {desc = mappings.search.description;})
        ];
      };

      binds.whichKey.register = mkIf config.vim.vendoredKeymaps.enable (pushDownDefault {
        "<leader>g" = "+Git";
      });
    };
  };
}
