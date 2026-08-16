{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.illuminate;
in {
  config = mkIf cfg.enable {
    # vim-illuminate does not have a setup function. It is instead called
    # 'configure' and does what you expect from a setup function.
    vim.lazy.plugins.vim-illuminate = {
      package = "vim-illuminate";
      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
      after = ''
        require('illuminate').configure(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
