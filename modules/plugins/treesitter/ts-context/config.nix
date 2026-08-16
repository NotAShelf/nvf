{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  inherit (config.vim) treesitter;
  cfg = treesitter.context;
in {
  config = mkIf (treesitter.enable && cfg.enable) {
    vim.lazy.plugins.nvim-treesitter-context = {
      package = "nvim-treesitter-context";
      setupModule = "treesitter-context";
      inherit (cfg) setupOpts;
      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
      cmd = ["TSContext"];
    };
  };
}
