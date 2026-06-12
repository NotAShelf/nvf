{
  pkgs,
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.preview.glow;
  inherit (options.vim.utility.preview.glow) mappings;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["glow-nvim"];

    keymaps = [
      (mkKeymap "n" cfg.mappings.openPreview ":Glow<CR>" {desc = mappings.openPreview.description;})
    ];

    binds.whichKey.register = pushDownDefault {
      "<leader>pm" = "+Preview Markdown";
    };

    pluginRC.glow = entryAnywhere ''
      require('glow').setup({
        glow_path = "${pkgs.glow}/bin/glow"
      });
    '';
  };
}
