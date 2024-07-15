{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;

  cfg = config.vim.notes.mind-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "mind-nvim"
      ];

      maps.normal = {
        "<leader>om" = {action = ":MindOpenMain<CR>";};
        "<leader>op" = {action = ":MindOpenProject<CR>";};
        "<leader>oc" = {action = ":MindClose<CR>";};
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>o" = "+Notes";
      };

      pluginRC.mind-nvim = entryAnywhere ''
        require'mind'.setup()
      '';
    };
  };
}
