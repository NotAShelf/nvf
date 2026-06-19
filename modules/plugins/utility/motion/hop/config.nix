{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.motion.hop;

  inherit (options.vim.utility.motion.hop) mappings;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["hop.nvim"];

    keymaps = [
      (mkKeymap "n" cfg.mappings.hop "<cmd>HopPattern<CR>" {desc = mappings.hop.description;})
    ];

    pluginRC.hop-nvim = entryAnywhere ''
      require('hop').setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
