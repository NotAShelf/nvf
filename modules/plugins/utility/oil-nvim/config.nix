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

      pluginRC.oil-nvim = let
        gitStatusDefaultOpts = {
          # https://github.com/refractalize/oil-git-status.nvim?tab=readme-ov-file#configuration
          win_options = {
            signcolumn = "yes:2";
          };
        };

        setupOpts =
          recursiveUpdate
          (optionalAttrs cfg.gitStatus.enable gitStatusDefaultOpts)
          cfg.setupOpts;
      in
        entryAnywhere ''
          require("oil").setup(${toLuaObject setupOpts});
        '';

      pluginRC.oil-git-status-nvim = mkIf cfg.gitStatus.enable (entryAfter ["oil-nvim"] ''
        require("oil-git-status").setup(${toLuaObject cfg.gitStatus.setupOpts})
      '');
    };
  };
}
