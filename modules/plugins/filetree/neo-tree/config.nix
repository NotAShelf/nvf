{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.filetree.neo-tree;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        # dependencies
        "plenary-nvim" # commons library
        "image-nvim" # optional for image previews
        "nui-nvim" # ui library
      ];

      lazy.plugins.neo-tree-nvim = {
        package = "neo-tree-nvim";
        setupModule = "neo-tree";
        inherit (cfg) setupOpts;

        cmd = ["Neotree"];
      };

      visuals.nvim-web-devicons.enable = true;
      # from https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/1326
      pluginRC.neo-tree =
        mkIf (cfg.setupOpts.filesystem.hijack_netrw_behavior != "disabled" && config.vim.lazy.enable)
        (entryAnywhere ''
          vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("load_neo_tree", {}),
            desc = "Loads neo-tree when openning a directory",
            callback = function(args)
              local stats = vim.uv.fs_stat(args.file)

              if not stats or stats.type ~= "directory" then
                return
              end

              require("lz.n").trigger_load("neo-tree-nvim")

              return true
            end,
          })
        '');
    };
  };
}
