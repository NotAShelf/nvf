{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.lsp;

  inherit (options.vim.lsp.otter-nvim) mappings;
in {
  config = mkIf (cfg.enable && cfg.otter-nvim.enable) {
    vim.lazy.plugins = {
      "otter-nvim" = {
        package = "otter-nvim";
        setupModule = "otter";
        inherit (cfg.otter-nvim) setupOpts;

        cmd = ["OtterActivate" "OtterDeactivate" "OtterExport" "OtterExportAs"];

        keys = [(mkKeymap "n" cfg.otter-nvim.mappings.toggle "<cmd>OtterActivate<CR>" {desc = mappings.toggle.description;})];
      };
    };
  };
}
