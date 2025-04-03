{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.motion.flash-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins = {
        "flash-nvim" = {
          package = "flash-nvim";
          setupModule = "flash";
          setupOpts = cfg.setupOpts;

          lazy = true;

          keys = [
            (mkKeymap ["n" "o" "x"] cfg.mappings.jump "<cmd>lua require(\"flash\").jump()<cr>" {desc = "Flash";})
            (mkKeymap ["n" "o" "x"] cfg.mappings.treesitter "<cmd>lua require(\"flash\").treesitter()<cr>" {desc = "Flash Treesitter";})
            (mkKeymap "o" cfg.mappings.remote "<cmd>lua require(\"flash\").remote()<cr>" {desc = "Remote Flash";})
            (mkKeymap ["o" "x"] cfg.mappings.treesitter_search "<cmd>lua require(\"flash\").treesitter_search()<cr>" {desc = "Treesitter Search";})
            (mkKeymap "c" cfg.mappings.toggle "<cmd>lua require(\"flash\").toggle()<cr>" {desc = "Toggle Flash Search";})
          ];
        };
      };
    };
  };
}
