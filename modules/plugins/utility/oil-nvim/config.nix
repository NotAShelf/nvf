{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) optionalAttrs recursiveUpdate;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter entryAnywhere;

  cfg = config.vim.utility.oil-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["oil-nvim"] ++ (optionals cfg.gitStatus.enable ["oil-git-status.nvim"]);

      pluginRC.oil-nvim = entryAnywhere ''
        require("oil").setup(${toLuaObject (recursiveUpdate (optionalAttrs cfg.gitStatus.enable {
            # https://github.com/refractalize/oil-git-status.nvim?tab=readme-ov-file#configuration
            win_options = {
              signcolumn = "yes:2";
            };
          })
          cfg.setupOpts)});
      '';

      pluginRC.oil-git-status-nvim = entryAfter ["oil-nvim"] ''
        require("oil-git-status").setup(${toLuaObject cfg.gitStatus.setupOpts})
      '';
    };
  };
}
