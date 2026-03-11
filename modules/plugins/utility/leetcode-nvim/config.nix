{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.leetcode-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "plenary-nvim"
        "fzf-lua"
        "nui-nvim"
      ];

      lazy.plugins.leetcode-nvim = {
        package = "leetcode-nvim";
        setupModule = "leetcode";
        inherit (cfg) setupOpts;
      };

      telescope.enable = true;
    };
  };
}
