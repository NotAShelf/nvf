{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.edgy-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["edgy-nvim"];
      pluginRC.edgy-nvim = entryBefore ["basic"] ''
        ${optionalString cfg.setRecommendedNeovimOpts ''
          -- Neovim options recommended by upstream.
          -- Views can only be fully collapsed with the global statusline.
          vim.o.laststatus = 3
          -- Default splitting will cause your main splits to jump when opening an edgebar.
          -- To prevent this, set `splitkeep` to either `screen` or `topline`.
          vim.o.splitkeep = "screen"
        ''}

        require('edgy').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
