{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim defaultAttributes;

  cfg = config.vim.notes.mind-nvim;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "mind-nvim"
    ];

    vim.maps.normal = {
      "<leader>om" = {action = ":MindOpenMain<CR>";};
      "<leader>op" = {action = ":MindOpenProject<CR>";};
      "<leader>oc" = {action = ":MindClose<CR>";};
    };

    vim.binds.whichKey.register = defaultAttributes {
      "<leader>o" = "+Notes";
    };

    vim.luaConfigRC.mind-nvim = nvim.dag.entryAnywhere ''
      require'mind'.setup()
    '';
  };
}
